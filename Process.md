# Steps for analysis
0. clipdatafiles.R
    - Trim environmental datasets to CA
1. sampledata.R : 
    - randomly assign points in California
    - randomly assign positive cases
    - created dataframe with sample number, lat, long, status, sex, age, date
2. case_distmetrics.R : calculate distance measures. 
    - mean distance from positive cases
    - distance to nearest positive case
    - distance to CA border
3. Make buffers & pull data!
    - make buffers 5km2
    - tabulate intersect landcover within buffer
    - Ruggedness (sd of elevation within buffer) 
    - highway density within buffer
4. Rare-events Logistic Regression


