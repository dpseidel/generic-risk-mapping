## rasters.R 
##
## Author: Dana Seidel
## Date: February 2018
##
## Script to prepare statewide rasters of covariates and 
## predict new risk map from relogit model.
##

library(sf)
library(tidyverse)
library(raster)
library(velox)
library(fasterize) # makes raster play nice with sf


# load data
#samples <- st_read("datafiles/points_aea.shp")
CApoly <- st_read("datafiles/CA_aea.shp")
elevation <- raster("datafiles/ca_DEM_aea.tif")
highways <- st_read("datafiles/highways.shp") 

# Using our model from regression.R
# we need a ruggedness raster, resampling DEM
# and we need a road_density raster

# set up
cell_side = area_2_rd(5000000) * 2  # function defined in buffermetrics.R

grid <- st_make_grid(CApoly, cellsize = cell_side, crs=LC_proj) %>% 
  st_sf %>% mutate(cellid = 1:n())

### Ruggedness Raster
vx_elev <- velox(elevation)
rugg_grid <- grid %>% mutate(rugg = vx_elev$extract(grid,sd))
r <- raster(extent(CApoly), res = cell_side)
rugg_raster <- fasterize(rugg_grid, r, field = "rugg")

### roaddensity
linedensity <- function(polygons, polylines){
    st_intersection(polylines, polygons) %>% 
    mutate(length = st_length(.)) %>% 
    group_by(cellid) %>%             # TODO use quosure to make the ID variable dynamic
    summarise(road_length = as.vector(sum(length)), 
              road_density = as.vector(road_length/(cell_side^2))) %>% 
    st_set_geometry(NULL) %>% 
    right_join(polygons) %>% 
    replace_na(list(road_density=0)) %>%
    pull(road_density) %>% return()
}

road_grid <- grid %>% mutate(rd_dens = linedensity(grid, highways))
r <- raster(extent(CApoly), res = cell_side)
road_raster <- fasterize(road_grid, r, field = "rd_dens")


##### RASTER PREDICTION - RISK MAPPING #####
# predict off this model from regression.R
#model <- relogit(status ~  sex + age + time + ruggedness + road_density,
#                 data = data)
# plot statewide risk for adult male, 5 years out from infection
# stack ruggedness and road_density rasters
# and some constants. 
constant1 <- road_raster %>% setValues(1)
constant5 <- road_raster %>% setValues(5)

cov_stack <- stack(constant1, constant1, constant5, rugg_raster, road_raster)
names(cov_stack) <- c("sex", "age", "time", "ruggedness", "road_density")

risk_map <- raster::predict(cov_stack, model)
plot(risk_map)
