#' convert NOAA GEFS forecast to water temperature and uPAR forecast using
#' output from linear regression models of NEON variables
#'
#' @param start_date start date for forecast
#' @param lm_wt output of get_NEON_lm function for air temperature and water temperature
#' @param lm_upar output of get_NEON_lm function for shortwave radiation and uPAR
#' @param noaa_fc NOAA GEFS forecast with a start date equal to start_date

convert_forecast <- function(noaa_fc, start_date){
  
  fc_data = noaa_fc
  
  fc_idx <- fc_data[[start_date]]
  
  fc_conv_list <- lapply(1:31, function(x) {
    df <- noaa_fc[[start_date]]
    sub <- df[(df[, 2] %in% c("air_temperature",
                              "surface_downwelling_shortwave_flux_in_air",
                              "wind_speed")), c(1, 2, 2 + x)]
    df2 <- tidyr::pivot_wider(data = sub, id_cols = time, names_from = L1, values_from = 3)
    df2$air_temperature <- df2$air_temperature - 273.15
    df2$date <- as.Date(df2$time)
    df2$time <- NULL
    df3 <- plyr::ddply(df2, "date", function(y){
      colMeans(y[, 1:3], na.rm = TRUE)
    })
    # df3 <- df3[2:16, ]
    fc_out_dates <<- df3$date

    df3$fc_date <- "2020-09-25"
    # progress$set(value = x/30)
    return(df3)
  })
  
  l1 <- fc_conv_list
  idvars <- colnames(l1[[1]])
  mlt1 <- tibble(reshape::melt(l1, id.vars = idvars))
  colnames(mlt1)[c(2:4,6)] <- c("air_temperature","shortwave_radiation","wind_speed","ensemble_member")
  
  met_forecast <- mlt1 %>%
    pivot_longer(air_temperature:wind_speed, names_to = "variable",values_to = "value") %>% 
    select(-fc_date) %>%
    mutate(date = as.Date(date)) %>%
    filter(date <= "2020-10-02")

  colnames(met_forecast)[1] <- "forecast_date"
  
  airtemp_fc <- met_forecast %>%
    filter(variable == "air_temperature")
  
  return(list(met_forecast = met_forecast,
              airtemp_fc = airtemp_fc))
}
