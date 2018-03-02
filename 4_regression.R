## regression.R 
##
## Author: Dana Seidel
## Date: February 2018
##
## Script to fit rare events logistic regression for risk mapping. 
##

library(tidyverse)
library(Zelig)

# data

samples_fullvars  # calculated via scripts 1. & 2. or read in below
# samples_fullvars <- st_read("datafiles/samples_fullvars.shp")

# time (yrs) since first positive varible 
# make things binary

data <- samples_fullvars %>% 
  mutate(status = ifelse(Status == "NEG", 0, 1), 
            age = ifelse(age == "Juv", 0, 1), 
            sex = ifelse(sex == "F", 0, 1),
            time = year(date) - 2000)


# check correlations
data %>% na.omit %$% cor(ruggedness, dst_border)
data %>% na.omit %$% cor(ruggedness, time)


model <- relogit(status ~  sex + age + time + ruggedness + dst_border,
                 data = data)

### standardize coefficients
Relogit.beta <- function(MOD){
  b <- as.vector(summary(MOD)$coef[-1,1])
  sx <- map_dbl(MOD$model[-1], sd)
  sy <-  map_dbl(MOD$model[1], sd)
  beta <- b * sx/sy
  return(beta)
}

Relogit.beta(model)


# TODO: build prpoer rasters for predict --> risk map. 
