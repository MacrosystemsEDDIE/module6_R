#Data prep for Mod 6 R version

library(tidyverse)
library(lubridate)

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
