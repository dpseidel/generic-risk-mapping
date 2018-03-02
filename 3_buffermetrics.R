## BufferMetrics.R 
## A script to generate buffer polygons and calculate density and ruggedness 
## covariates
##
## Author: Dana Seidel
## Date: February 2018

# load packages
library(sf)
library(tidyverse)
library(raster)
library(velox)
library(fasterize) # makes raster play nice with sf


# load data
#samples <- st_read("datafiles/points_aea.shp")
elevation <- raster("datafiles/ca_DEM_aea.tif")
landcover <- raster("datafiles/ca_landcover.tif")
highways <- st_read("datafiles/highways.shp")

# area to radius function to programatically calculate buffer radius
area_2_rd <- function(a){
  sqrt(a/pi)
}
area = 5000000
buffers <- st_buffer(samples, dist=area_2_rd(area))

# Elevation Covariate
vx_elev <- velox(elevation)

# LandCover Covariate
# we want 
# percentage agriculture in the buffer (value code: 81/82)
# percentage forest cover (value code: 41,42,43)
# percentage grassland (value code: 71)
vx_LC <- velox(landcover)
LC_proportions <- vx_LC$extract(buffers, df=TRUE) %>% 
  rename(buffer_id = ID_sp, LC_code = do.call..rbind...out.) %>% 
  mutate(class = ifelse(LC_code == 71, "grassland", 
                        ifelse(LC_code %in% c(41, 42,43), "forest", 
                               ifelse(LC_code %in% c(81,82), "agriculture",
                                      "other")))) %>% 
  group_by(buffer_id, class) %>% 
  summarise(proportion = round(n()/500, 2)) %>% 
  spread(., key = class, value = proportion, fill = 0) %>% select(-`<NA>`)

# RoadDensity Covariate
inter <- buffers %>% 
  st_intersection(highways, .) %>% 
  mutate(length = st_length(.)) %>% 
  group_by(SampleNo) %>% 
  summarise(road_length = as.vector(sum(length)), road_density = as.vector(road_length/area)) %>% 
  st_set_geometry(NULL)

samples_fullvars <- samples %>%
  mutate(ruggedness = as.vector(vx_elev$extract(buffers, sd))) %>%
  left_join(LC_proportions, by = c("SampleNo" = "buffer_id")) %>%
  left_join(inter) %>% replace_na(list(road_length=0, road_density=0))

  

