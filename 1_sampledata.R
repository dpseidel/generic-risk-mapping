## SampleData.R 
## The script where I generate sample case data for a generic wildlife disease
## in california. 
## Cases represent an individual animal that tested positive for the disease
## NonCases represent an animal that tested negative for the disease.
##
## Author: Dana Seidel
## Date: February 22, 2018
library(sf)
library(tidyverse)
library(lubridate)
library(mapview)

CApoly <- st_read("datafiles/CA_aea.shp")

set.seed(5678)

# to make it a little more interesting/stratified make a sampling zone
# and an infection zone
#start with an arbitrary pt in NV, make a big buffer, clip by CA
init_pt <- st_point(c(-116, 38.8)) %>% 
  st_sfc %>% st_set_crs("+proj=longlat") %>% 
  st_transform(st_crs(CApoly))
sample_zone <- st_buffer(infect_pt, dist = 450000) %>%
  st_intersection(CApoly)
infect_pt <- st_point(c(-115.1398, 36.1699)) %>%  #infection begins in Las Vegas
  st_sfc %>% st_set_crs("+proj=longlat") %>% 
  st_transform(st_crs(CApoly))
infect_zone <- st_buffer(infect_pt, dist = 200000) %>%
  st_intersection(CApoly)

sample_points <- st_sample(sample_zone, rnorm(1,10000,1000)) %>% 
  st_sf(geometry = .) %>% mutate(inzone = as_vector(st_intersects(.,infect_zone, sparse = F)), 
                                 randomsample = sample(0:1000, n(), replace = TRUE), 
                                 insample = ifelse(randomsample<50, TRUE, FALSE), 
                                 Status = as.vector(ifelse(inzone & insample, "POS", "NEG")),
                                 SampleNo = seq(1, n(), 1)) %>% 
  sf::select.sf(-inzone, -randomsample, -insample) %>% cbind(st_coordinates(.))

# make sure we have at least some positives
sample_points %>% group_by(Status) %>% tally
# perfect

# make some covariates
date_range <- seq(ymd('2000/01/01'), ymd('2005/12/31'), by="day")
samples <- sample_points %>% mutate(sex = sample(c("M","F"), size=n(), replace = T),
                         age = sample(c("Adult","Juv"), size=n(), replace = T),
                         date = sample(date_range, n(), replace = T))  # TODO: sample in such a way that there is growth over time.  

# set date of intial positive, closest one to CA_border
# Sample 2372
samples[2372, "date"] <- ymd("2000-01-01")

# samples %>% write_sf("datafiles/points_aea.shp")

# clean up environment before step 3
# rm(infect_pt, infect_zone, sample_zone, init_pt, sample_points, date_range)
