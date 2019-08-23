#Loading in libraries U PROLLY DIDN'T USE THEM ALL SO CHECK
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

#Let's start by setting up working directories and loading in files.
#Load in raw precinct voting data for US senate and house from MA state:
setwd("~/GitHub/elections-map")
fed <- read.csv("mass_federal.csv")

#Loading in a precincts crosswalk file I created between Mass state shapefile data and cleaned MEDSL Mass data:
pxwalk <- read.csv("precincts_crosswalk.csv")

#Reading in and exploring shape file/GIS data from Mass Gov:
setwd("C:/Users/User/Documents/MA_project/wardsprecincts_poly")
magis <- readOGR("WARDSPRECINCTS_POLY.shp")
magis@data

#Now let's subset out US Senate data, of which election results are what we focus on in this project:
MAsen <- fed[fed$office=="US Senate" & (fed$name=="Elizabeth A. Warren" | fed$name=="Geoff Diehl"),]

#NOTE: In orer to simplify the visualisation process, I removed data regarding votes for the independent senate candidate, blank votes, and votes titled "all other". Treating the race as a purely bipartisan and only looking at the subset of people who voted for Warren or Diehl race may lead to inaccuracies or misleading ideas, but the median percentage of votes that didn't go to these two candidates per town is 5.2% which is low and may not affect results too heavily.

#Creating variable to join with crosswalk and shape file
WP <- case_when(!MAsen$ward=="-" ~ paste(MAsen$ward,MAsen$precinct,sep="-"),
                TRUE ~ as.character(MAsen$precinct))
MAsen$xwalk<-paste(MAsen$town,WP,sep=" ")

#Summing votes in each precinct for Elizabeth Warren
warren<-aggregate(MAsen$votes[MAsen$name=="Elizabeth A. Warren"], by=list(Category=MAsen$xwalk[MAsen$name=="Elizabeth A. Warren"]), FUN=sum)
colnames(warren) <- c("Town", "Votes for Elizabeth A. Warren")
#Summing votes in each precinct for Geoff Diehl
diehl<-aggregate(MAsen$votes[MAsen$name=="Geoff Diehl"], by=list(Category=MAsen$xwalk[MAsen$name=="Geoff Diehl"]), FUN=sum)
colnames(diehl) <- c("Town", "Votes for Geoff Diehl")
#Summing total votes in each precinct (pretending the only two candidates were Warren and Diehl)
total<-aggregate((MAsen$votes), by=list(Category=MAsen$xwalk), FUN=sum)
colnames(total) <- c("Town", "Total Votes")

#Calculating proportions of votes in each town
warrenproportion <- warren$`Votes for Elizabeth A. Warren`/total$`Total Votes` * 100
warrenproportion <- round(warrenproportion,1)
diehlproportion <- diehl$`Votes for Geoff Diehl`/total$`Total Votes` * 100
diehlproportion <- round(diehlproportion,1)
votes<-cbind(warren$`Town`,warren$`Votes for Elizabeth A. Warren`,diehl$`Votes for Geoff Diehl`,total$`Total Votes`, warrenproportion,diehlproportion)
colnames(votes) <- c("xwalk", "Votes for Elizabeth A. Warren", "Votes for Geoff Diehl", "Total Votes", "Percentage of Votes for Warren", "Percentage of Votes for Diehl")

#Attribute joining precinct vote data to GIS data
magis@data<-left_join(magis@data,pxwalk,by=c('WP_NAME'='gis_precincts'))
votes<-as.data.frame(votes)
magis@data<-left_join(magis@data,votes,by=c('medsl_precinct_1'='xwalk'))

#Mapping
#magis@data<-rbind(magis@data[1:2033,],magis@data[2035:2152,],magis@data[2034,])
#magis@data<-magis@data[order(magis@data$`Percentage of Votes for Warren`),]
magis@data$`Percentage of Votes for Warren`<-gsub(100,NA,magis@data$`Percentage of Votes for Warren`)
MyPal <- c('#FFCBCB','#CCE5FF','#3399FF','#1F52FC','#0000CC')

tm_shape(magis)+
  tm_polygons("Percentage of Votes for Warren", id=c("WP_NAME"), palette=MyPal, popup.vars=c("% of votes for Elizabeth Warren"="Percentage of Votes for Warren", "# of votes for Elizabeth Warren"="Votes for Elizabeth A. Warren", "# of votes for Geoff Diehl"="Votes for Geoff Diehl"),legend.show=FALSE)+
  tmap_options(max.categories = 5)

tmap_mode("view")
tmap_last()
