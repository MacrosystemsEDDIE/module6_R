#Data prep for Mod 6 R version

library(tidyverse)
library(lubridate)
library(ncdf4)
library(reshape)

####DATA WRANGLING FOR LAKE DATA####

# Read in air temperature data for Lake Barco
# We are calling the air temperature data "xvar" because we are using it as a predictor of water temperature
xvar <- read.csv("./data/BARC_airt_celsius.csv") 

# Data wrangling to reformat dates 
xvar$Date <- as.Date(xvar[, 1])

# Data wrangling to calculate daily average air temperature
xvar <- plyr::ddply(xvar, c("Date"), function(x) mean(x[, 2], na.rm = TRUE)) 

# Read in surface water temperature data
# We are calling this "yvar" because it is the variable we are trying to predict
yvar <- read.csv("./data/BARC_wtemp_celsius.csv")

# Data wrangling to reformat dates
yvar$Date <- as.Date(yvar[, 1])

# Data wrangling to subset water temperature to only surface temperature and calculate daily average
yvar <- yvar[yvar[, 2] == min(yvar[, 2], na.rm = TRUE), c(1, 3)] # subset to Surface water temperature
yvar <- plyr::ddply(yvar, c("Date"), function(y) mean(y[, 2], na.rm = TRUE)) # Daily average 

# Combine air temperature and surface water temperature into one dataframe
lake_df <- merge(xvar, yvar, by = "Date")

# Subset to the months of May-October (when data is available for most NEON lakes)
lake_df$month <- lubridate::month(lake_df$Date)
lake_df <- lake_df[(lake_df$month %in% 5:10), 1:3]

# Rename columnns to sensible names after joining
colnames(lake_df)[-1] <- c("airt", "wtemp")

# Limit data to complete cases (rows with both air and water temperature available)
lake_df$airt[is.na(lake_df$wtemp)] <- NA
lake_df$wtemp[is.na(lake_df$airt)] <- NA
lake_df <- lake_df[which(complete.cases(lake_df)),]

# Write to file
write.csv(lake_df, file = "./assignment/data/BARC_airt_wtemp_celsius.csv", row.names = FALSE)

####DATA WRANGLING FOR NOAA FORECAST ####

# Name our forecast date: we will be working with a NOAA forecast generated on 2020-09-25
fc_date = "2020-09-25"

# Name the file path where we can find the NOAA forecast 
fpath <- file.path("./data/NOAA_FC_BARC")

# Name the forecast variables we want to retrieve: in our case, we are interested in air temperature
fc_vars <- "air_temperature"

# Sequentially read in and re-format several netcdf files containing forecast information so that we end up with a two-dimensional data frame containing a 7-day-ahead air temperature forecast with 30 ensemble members
out <- lapply(fc_date, function(dat) {
  
  idx <- which(fc_date == dat)
  
  fils <- list.files(fpath)
  fils <- fils[-c(grep("ens00", fils))]
  
  for( i in seq_len(length(fils))) {
    
    fid <- ncdf4::nc_open(file.path("./data/NOAA_FC_BARC", fils[i]))
    tim = ncvar_get(fid, "time")
    tunits = ncatt_get(fid, "time")
    lnam = tunits$long_name
    tustr <- strsplit(tunits$units, " ")
    step = tustr[[1]][1]
    tdstr <- strsplit(unlist(tustr)[3], "-")
    tmonth <- as.integer(unlist(tdstr)[2])
    tday <- as.integer(unlist(tdstr)[3])
    tyear <- as.integer(unlist(tdstr)[1])
    tdstr <- strsplit(unlist(tustr)[4], ":")
    thour <- as.integer(unlist(tdstr)[1])
    tmin <- as.integer(unlist(tdstr)[2])
    origin <- as.POSIXct(paste0(tyear, "-", tmonth,
                                "-", tday, " ", thour, ":", tmin),
                         format = "%Y-%m-%d %H:%M", tz = "UTC")
    if (step == "hours") {
      tim <- tim * 60 * 60
    }
    if (step == "minutes") {
      tim <- tim * 60
    }
    time = as.POSIXct(tim, origin = origin, tz = "UTC")
    
    var_list <- lapply(fc_vars,function(x){
      data.frame(time = time, value = (ncdf4::ncvar_get(fid, x) -  273.15))
    })
    
    ncdf4::nc_close(fid)
    names(var_list) <- fc_vars
    
    mlt1 <- reshape::melt(var_list, id.vars = "time")
    mlt1 <- mlt1[, c("time", "L1", "value")]
    
    cnam <- i
    if(i == 1) {
      df2 <- mlt1
      colnames(df2)[3] <- cnam
    } else {
      df2 <- merge(df2, mlt1, by = c(1,2))
      colnames(df2)[ncol(df2)] <- cnam
    }
    
  }
  return(df2)
})

names(out) <- fc_date

noaa_fc <- reshape::melt(out[[1]][out[[1]]$L1 == "air_temperature", ], id.vars = c("time", "L1"))

noaa_fc$Date <- as.Date(noaa_fc$time)
noaa_fc <- plyr::ddply(noaa_fc, c("Date", "L1", "variable"), function(x) data.frame(value = mean(x$value, na.rm = TRUE)))
noaa_fc <- noaa_fc[noaa_fc$Date <= "2020-10-02", ]
colnames(noaa_fc) <- c("Forecast_date","Forecast_variable","Ensemble_member","value")

write.csv(noaa_fc, "./assignment/data/BARC_airt_forecast_NOAA_GEFS.csv", row.names = FALSE)

