# Predicting generic spatial risk

This repository contains code and sample data for creating a generic risk map using rare-events logistic regression in R. I have built this repository as a means to share some of the code and procedures I used for analysis on a private project requiring discretion. The original premise of these analyses was the assessment of spatial risk factors for a rare wildlife disease however, in practice these examples could be applied to any geospatial analysis asking the question: how does X spatial variable impact the likelihood of Y spatial sample occuring (if Y is a rare event)? 
The code in this repository primarly demonstrates geospatial analyses often left to software like QGIS or ArcGIS in R. For example, code included shows:
- how to calculate the density of linear features within a polygon 
- how to calculate distance-to variables between points in space and between points
- how to extract values within a polygon from a raster 
- how to tabulate an intersection between polygon and raster layers 

Please consult `Process.md` for the proper workflow.

#### Additional Notes:
In order to demonstrate the proper steps of spatial analysis I have chosen a random location, the state of California, but real spatial covariate layers to analyze: elevation, roads, and landcover. On principle, the "case data" provided does not represent any specific wildlife disease and has been produced entirely randomly for reproducible example purposes only (see `sampledata.R`).

This repository was built to serve as a part of my application to the Rstudio Summer Internship 2018 though the analyses for the original project began in September 2016. 

All shapefiles were downloaded from publicly available sources:
- Highways: https://earthworks.stanford.edu/catalog/stanford-xc453kn9742
- Land Cover: https://earthworks.stanford.edu/catalog/stanford-wv372bn9329
- CA boundary: https://earthworks.stanford.edu/catalog/tufts-cacensusboundary10
- Elevation: https://earthexplorer.usgs.gov/, https://lta.cr.usgs.gov/GMTED2010