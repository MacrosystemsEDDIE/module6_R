#Data prep for Mod 6 R version

library(tidyverse)
library(lubridate)
library(ncdf4)
library(neonUtilities)

#define NEON token
source("./module_admin/neon_token_source.R")

####DATA WRANGLING FOR LAKE DATA####

########### Windspeed

#Using this data product for windspeed: https://data.neonscience.org/data-products/DP1.20059.001

wnd <- loadByProduct(dpID="DP1.20059.001", site=c("BARC"),
                     startdate="2018-05", enddate="2020-10", 
                     package="basic",
                     tabl="WSDBuoy_30min",
                     token = NEON_TOKEN,
                     check.size = F)

# unlist the variables and add to the global environment
list2env(wnd, .GlobalEnv)

#format data
wnd2 <- WSDBuoy_30min %>%
  select(siteID, startDateTime, buoyWindSpeedMean) %>%
  mutate(date = date(startDateTime)) %>%
  rename(lake = siteID) %>%
  group_by(lake, date) %>%
  summarize(wnd = mean(buoyWindSpeedMean, na.rm = TRUE)) %>%
  arrange(lake, date) %>%
  ungroup() %>%
  select(-lake)

#plot formatted data
ggplot(data = wnd2, aes(x = date, y = wnd))+
  geom_point()+
  theme_bw()

# Read in air temperature data for Lake Barco
# We are calling the air temperature data "xvar" because we are using it as a predictor of water temperature
xvar <- read.csv("./data/BARC_airt_celsius.csv") 

# Data wrangling to reformat dates 
xvar$Date <- as.Date(xvar[, 1])

# Data wrangling to calculate daily average air temperature
xvar <- plyr::ddply(xvar, c("Date"), function(x) mean(x[, 2], na.rm = TRUE)) 

# Read in surface water temperature data
# We are calling this "yvar" because it is the variable we are trying to predict
yvar <- read.csv("./module_admin/BARC_wtemp_celsius.csv")

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
colnames(lake_df) <- c("date", "airt", "wtemp")

# Limit data to complete cases (rows with both air and water temperature available)
lake_df$airt[is.na(lake_df$wtemp)] <- NA
lake_df$wtemp[is.na(lake_df$airt)] <- NA
lake_df <- lake_df[which(complete.cases(lake_df)),]

# Write to file
write.csv(lake_df, file = "./assignment/data/BARC_airt_wtemp_celsius.csv", row.names = FALSE)

#left join to shortwave and windspeed data
sw <- read.csv("./data/BARC_swr_wattsPerSquareMeter.csv") %>%
  rename(swr = V1) %>%
  mutate(date = as.Date(Date)) %>%
  select(-Date)

lake_df <- left_join(lake_df, sw, by = "date") %>%
  left_join(., wnd2, by = "date") 

lake_df2 <- lake_df %>%
  pivot_longer(airt:wnd, names_to = "variable", values_to = "value")

write.csv(lake_df2, file = "./assignment/data/BARC_lakedata.csv", row.names = FALSE)
write.csv(lake_df2, file = "./data/BARC_lakedata.csv", row.names = FALSE)


####DATA WRANGLING FOR NOAA FORECAST ####
source("./module_admin/load_noaa_forecast.R")
source("./module_admin/convert_forecast.R")
library(reshape)


#set siteID
siteID = "BARC"

# Name our forecast date: we will be working with a NOAA forecast generated on 2020-09-25
start_date = "2020-09-25"

# read in forecasts 
noaa_fc <- load_noaa_forecast(siteID = siteID,
                          start_date = start_date)

#reformat forecasts
out <- convert_forecast(noaa_fc = noaa_fc,
                        start_date = start_date)

#check to make sure looks ok
ggplot(data = out$met_forecast, aes(x = forecast_date, y = value))+
  facet_grid(rows = vars(variable), scales = "free_y")+
  geom_point()+
  theme_bw()

write.csv(out$met_forecast, file = "./assignment/data/BARC_forecast_NOAA_GEFS.csv", row.names = FALSE)
write.csv(out$airtemp_fc, file = "./assignment/data/BARC_airt_forecast_NOAA_GEFS.csv", row.names = FALSE)
