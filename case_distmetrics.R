## case_distmetrics.R 
##
## Author: Dana Seidel
## Date: January 2018
##
## Script for a function to calculate mean and minimum distance to positive cases
## between every point and the previous positives

library(sf)
library(tidyverse)

calc_dist_meas <- function(points, df_positives){
  points$mean_dist_pos <- NA
  points$nearest_pos <- NA

    for (i in 1:nrow(points)){
    prev_pos <- filter(df_positives, date < points[i, "date"]) 
    dist <- st_distance(points[i,], prev_pos) 
    points[i, "mean_dist_pos"] <- mean(dist)
    points[i, "nearest_pos"] <- min(dist)
  }
}

