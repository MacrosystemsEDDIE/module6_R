# Title: Plotting functions for Module 6: Understanding Uncertainty in Ecological Forecasts
# Author: Tadhg Moore, Mary Lofton
# Date: 20JUL23

library(tidyverse)
library(lubridate)


plot_lake_data <- function(lake_df){
  cols <- RColorBrewer::brewer.pal(8, "Dark2") # Set custom color palette for our plot - ooh we are fancy!! :-)
  
  ggplot() +
    geom_point(data = lake_df, aes(x = date, y = airt, color = "Air temperature")) +
    geom_point(data = lake_df, aes(x = date, y = wtemp, color = "Water temperature")) +
    scale_color_manual(values = cols[5:6], name = "") +
    ylab("Temperature (\u00B0C)") +
    xlab("Time") +
    guides(color = guide_legend(override.aes = list(size = 3))) +
    theme_bw(base_size = 18) +
    theme(legend.position = "bottom")
}

plot_airtemp_forecast <- function(lake_obs, noaa_fc, forecast_start_date){
  l.cols <- RColorBrewer::brewer.pal(8, "Set2")[-c(1, 2)] # Defining another custom color palette :-)
  
  ggplot() +
    geom_point(data = lake_obs, aes(x = date, y = airt, color = "Observed air temp.")) +
    geom_line(data = noaa_fc, aes(x = forecast_date, y = value, group = ensemble_member, color = "Forecasted air temp."), alpha = 0.6)+
    geom_vline(xintercept = as_date(forecast_start_date), linetype = "dashed") +
    ylab("Temperature (\u00B0C)") +
    theme_bw(base_size = 12) +
    scale_color_manual(values = c("Observed air temp." = l.cols[1], "Forecasted air temp." = "gray"),
                       name = "",
                       guide = guide_legend(override.aes = list(
                         linetype = c("solid","blank"),
                         shape = c(NA,16))))
}

mod_predictions_watertemp <- function(lake_df2, pred){
  cols <- RColorBrewer::brewer.pal(8, "Dark2") # Set custom color palette for our plot - ooh we are fancy!! :-)
  
  ggplot() +
    geom_point(data = lake_df2, aes(date, wtemp, color = "Observed")) +
    geom_line(data = pred, aes(date, model, color = "Modeled")) +
    ylab("Temperature (\u00B0C)") +
    xlab("Time") +
    scale_color_manual(values = c( "Observed" = "black", "Modeled" = cols[6]),
                       name = "",
                       guide = guide_legend(override.aes = list(
                         linetype = c("solid","blank"),
                         shape = c(NA,16)))) +
    theme_bw(base_size = 12) 
}

plot_forecast <- function(lake_obs, forecast, forecast_start_date, title){
  cols <- RColorBrewer::brewer.pal(8, "Dark2") # Set custom color palette for our plot - ooh we are fancy!! :-)
  
  label_df <- tibble(forecast_date = format(unique(forecast$forecast_date),"%b %d"),
                     timestep = c("\n t+0","\n t+1","\n t+2","\n t+3","\n t+4","\n t+5","\n t+6","\n t+7")) %>%
    mutate(labels = paste0(forecast_date, timestep)) 
  
  forecast <- forecast %>%
    mutate(forecast_date = format(forecast_date, "%b %d")) %>%
    left_join(label_df) %>%
    mutate(labels = factor(labels, levels = c(unique(label_df$labels))))
  
  lake_obs <- lake_obs %>%
    mutate(forecast_date = format(date, "%b %d")) %>%
    left_join(label_df) %>%
    mutate(labels = factor(labels, levels = c(unique(label_df$labels)))) %>%
    filter(!is.na(labels))
  
  ggplot() +
    geom_line(data = forecast, aes(x = labels, y = value, color = "Forecasted water temp.", group = ensemble_member)) +
    geom_point(data = lake_obs, aes(x = labels, y = wtemp, color = "Observed water temp.")) +
    geom_vline(xintercept = forecast$labels[1], linetype = "dashed") +
    ylab("Temperature (\u00B0C)") +
    theme_bw(base_size = 12) +
    scale_color_manual(values = c("Forecasted water temp." = cols[1],"Observed water temp." = cols[2]),
                       name = "",
                       guide = guide_legend(override.aes = list(
                         linetype = c("solid","blank"),
                         shape = c(NA, 16)))) +
    ggtitle(title)
}

plot_param_dist <- function(param_df){
  # Set colors
  l.cols <- RColorBrewer::brewer.pal(8, "Set2")[-c(1, 2)] # Defining another custom color palette :-)
  
  # Reshape data
  plot.params <- pivot_longer(param_df, cols = starts_with("beta"), names_to = "variable", values_to = "value")
  
  # Build plot
  ggplot(plot.params) +
    geom_density(aes(value), fill = l.cols[4], alpha = 0.5) +
    facet_wrap(~variable, nrow = 1, scales = "free_x") +
    theme_bw(base_size = 16)
}

plot_ic_dist <- function(curr_wt, ic_uc){
 
  #Set colors
  l.cols <- RColorBrewer::brewer.pal(8, "Set2")[-c(1, 2)] # Defining another custom color palette :-)
  
  #Build plot
  ggplot() +
    geom_vline(xintercept = curr_wt) +
    geom_density(aes(ic_uc), fill = l.cols[2], alpha = 0.3) +
    xlab("Temperature (\u00B0C)") +
    ylab("Density") +
    theme_bw(base_size = 18)+
    ggtitle("Initial condition distribution")
}

plot_partitioned_uc <- function(variance_df){
  cols2 <- ggthemes::ggthemes_data$colorblind$value # Set another custom plot color palette
  
  label_df <- tibble(forecast_date = format(unique(variance_df$forecast_date),"%b %d"),
                     timestep = c("\n t+0","\n t+1","\n t+2","\n t+3","\n t+4","\n t+5","\n t+6","\n t+7")) %>%
    mutate(labels = paste0(forecast_date, timestep)) 
  
  variance_df <- variance_df %>%
    mutate(forecast_date = format(forecast_date, "%b %d")) %>%
    left_join(label_df) %>%
    mutate(labels = factor(labels, levels = c(unique(label_df$labels))))
  
  ggplot() +
    geom_bar(data = variance_df, aes(x = labels, y = variance, fill = uc_type), stat = "identity", position = "stack") +
    ylab(expression(paste("Variance (\u00B0",C^2,")"))) +
    xlab("Forecasted date") +
    geom_vline(xintercept = variance_df$labels[1], linetype = "dashed") +
    scale_fill_manual(values = c("process" = cols2[1], "parameter" = cols2[2], "initial_conditions" = cols2[3],
                                 "driver" = cols2[4])) +
    #scale_x_date(date_breaks = "1 day", date_labels = "%b %d") +
    labs(fill = "Uncertainty") +
    theme_bw(base_size = 12)
}
