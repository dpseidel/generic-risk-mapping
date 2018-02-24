# Steps for analysis
0. Trim environmental datasets.
1. sampledata.R : 
    - randomly assign points in California
    - randomly assign positive cases
    - created dataframe with sample number, lat, long, status
3. spatialdata.R : calculate distance measures. 
    - mean distance from prior cases
    - minimum distance to prior case
    - distance to human development
    - distance to major river
4. Make buffers & pull data!
    1. make buffers
    2. tabulate intersection with landcover polygons
    3. extract values from rasters (DEM). 
5. Rare-events Logistic Regression


