# elections-map
  Interactive map of bipartisan votes in all 2152 Massachusetts precincts in the 2018 US Senate election
  (INSERT LINK HERE)

 ## Motivation
 The goal of this project is to create a user friendly interactive map of all bipartisan votes in all 2152 voting Massachusetts precincts for residents to see how their precinct voted in the 2018 US Senate election, where the democrat candidate was Elizabeth A. Warren and the republican candidate was Geoff Diehl. 
 
 Compared to towns, wards, or municipalities, precinct voting data is hard to come by and not readily available, yet is monumentally important in the study of election science. For example, the closest project in terms of similarity to mine is [WBUR's Mass election results](https://www.wbur.org/politicker/2016/11/08/massachusetts-election-map), which only goes as in depth of results from 256 towns rather than the 2152 precincts in Massachusetts. 

## Project
##### Loading in libraries
```{r}
library(rgdal)
library(tidyverse)
library(dplyr)
library(stringr)
library(tmap)
library(tmaptools)
library(shinyjs)
library(RColorBrewer)
library(leaflet)
library(scales)
library(viridis)
library(maptools)
```
