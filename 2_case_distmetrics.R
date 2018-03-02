## case_distmetrics.R 
##
## Author: Dana Seidel
## Date: January 2018
##
## Script to calculate distance variable for rare events regression
## Variables Incluce:
##  - mean distance to positive cases
##  - distance to nearest positive
##  - distance to CA boarder
library(sf)
library(tidyverse)

CApoly <-  st_read("datafiles/CA_aea.shp")
samples <- st_read("datafiles/points_aea.shp")
pos <- samples %>% filter(Status == "POS")

calc_dist_meas <- function(points, df_positives){
  points$mean_dist_pos <- NA
  points$nearest_pos <- NA
  
  for (i in 1:nrow(points)){
    prev_pos <- filter(df_positives, date <= points$date[i])
    dist <- st_distance(points[i,], prev_pos) 
    points[i, "mean_dist_pos"] <- mean(dist)
    points[i, "nearest_pos"] <- min(dist)
  }
  
  return(points)
}

samples <- calc_dist_meas(samples, pos) # this is slower than I would like. 

border <- CApoly %>% 
  st_cast(., "MULTILINESTRING") %>% 
  st_set_crs(st_crs(CApoly))

samples <- samples %>% 
  mutate(dst_border = as.vector(st_distance(., border, sparse=FALSE)))
