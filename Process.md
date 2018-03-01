# Steps for analysis
0. Trim environmental datasets.
1. sampledata.R : 
    - randomly assign points in California
    - randomly assign positive cases
    - created dataframe with sample number, lat, long, status, sex, age, date
3. case_distmetrics.R : calculate distance measures. 
    - mean distance from prior cases
    - minimum distance to prior case
4. Make buffers & pull data!
    1. make buffers 1km2
    2. percent coverage landcover
    3. Ruggedness (sd of elevation). 
5. Rare-events Logistic Regression


