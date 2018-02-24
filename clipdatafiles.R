## SampleData.R 
## The script where I trim environmental data files to the shape of california
## and sort out projection issues
##
## Author: Dana Seidel
## Date: February 22, 2018

library(sf)
library(tidyverse)
library(raster)
library(velox)
library(fasterize)


CA_bound_path <- list.files("raw_datafiles/caboundary/", 
                            pattern="*.shp", full.names = T)
CA_bounds <- st_read(CA_bound_path)

### landcover
## clip to california
## writeRaster
LC_path <- list.files("raw_datafiles/landcover/", 
                      pattern="*.tif$", full.names = T)
LC <- raster(LC_path)
LC_proj <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 
            +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

CA_aea_extent <- CA_bounds %>% st_transform(LC_proj) %>% as(., "Spatial") %>% extent()

# write proj points
# CA_aea <- st_transform(CA_bounds, LC_proj)
# st_write("datafiles/CA_aea.shp)

LC_crop <- crop(LC, CA_aea_extent)
# mask way way faster with raster, so in comes fasterize!
CA_raster <- fasterize(CA_aea, LC_crop)
LC_mask <- mask(LC_crop, CA_raster)

writeRaster(LC_mask, "datafiles/ca_landcover.tif")

### DEM
# velox makes the crop way faster
DEM_120_path <-  list.files("raw_datafiles/GMTED120/", 
                        pattern="*max075.tif$", full.names = T)
DEM_150_path <-  list.files("raw_datafiles/GMTED150/", 
                             pattern="*max075.tif$", full.names = T)
DEM_120 <- velox(DEM_120_path)
DEM_150 <- velox(DEM_150_path)
DEM_120$crop(CA_bounds)
DEM_150$crop(CA_bounds)
# merge
DEM_CA <- merge(DEM_120$as.RasterLayer(1), DEM_150$as.RasterLayer(1))
# mask
DEM_CA <- mask(DEM_CA, CA_raster)

# Project
DEM_CA_aea<- projectRaster(DEM_CA, crs = LC_proj)

## writeRaster
writeRaster(DEM_CA_aea, "datafiles/ca_DEM_aea.tif") # still 48 MB but not as insane. 



