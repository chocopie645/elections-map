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

setwd("C:/Users/User/Documents/GitHub/elections-map/elections-map")
fed <- read.csv("mass_federal.csv")

pxwalk <- read.csv("crosswalk.csv")

setwd("C:/Users/User/Documents/GitHub/elections-map/elections-map/wardsprecincts_poly")
magis <- readOGR("WARDSPRECINCTS_POLY.shp")
magis@data

MAsen <- fed[fed$office=="US Senate" & (fed$name=="Elizabeth A. Warren" | fed$name=="Geoff Diehl"),]

WP <- case_when(!MAsen$ward=="-" ~ paste(MAsen$ward,MAsen$precinct,sep="-"),
                TRUE ~ as.character(MAsen$precinct))
MAsen$xwalk<-paste(MAsen$town,WP,sep=" ")

warren<-aggregate(MAsen$votes[MAsen$name=="Elizabeth A. Warren"], by=list(Category=MAsen$xwalk[MAsen$name=="Elizabeth A. Warren"]), FUN=sum)
colnames(warren) <- c("Town", "Votes for Elizabeth A. Warren")
#Summing votes in each precinct for Geoff Diehl
diehl<-aggregate(MAsen$votes[MAsen$name=="Geoff Diehl"], by=list(Category=MAsen$xwalk[MAsen$name=="Geoff Diehl"]), FUN=sum)
colnames(diehl) <- c("Town", "Votes for Geoff Diehl")
#Summing total votes in each precinct (pretending the only two candidates were Warren and Diehl)
total<-aggregate((MAsen$votes), by=list(Category=MAsen$xwalk), FUN=sum)
colnames(total) <- c("Town", "Total Votes")

warrenproportion <- warren$`Votes for Elizabeth A. Warren`/total$`Total Votes` * 100
warrenproportion <- round(warrenproportion,1)
diehlproportion <- diehl$`Votes for Geoff Diehl`/total$`Total Votes` * 100
diehlproportion <- round(diehlproportion,1)
votes<-cbind(warren$`Town`,warren$`Votes for Elizabeth A. Warren`,diehl$`Votes for Geoff Diehl`,total$`Total Votes`, warrenproportion,diehlproportion)
colnames(votes) <- c("xwalk", "Votes for Elizabeth A. Warren", "Votes for Geoff Diehl", "Total Votes", "Percentage of Votes for Warren", "Percentage of Votes for Diehl")

magis@data<-left_join(magis@data,pxwalk,by=c('WP_NAME'='gis_precincts'))
votes<-as.data.frame(votes)
magis@data<-left_join(magis@data,votes,by=c('medsl_precinct_1'='xwalk'))


magis@data$`Percentage of Votes for Warren`<-gsub(100,NA,magis@data$`Percentage of Votes for Warren`)
MyPal <- c('#FFCBCB','#CCE5FF','#3399FF','#1F52FC','#0000CC')

map <- tm_shape(magis)+
  tm_polygons("Percentage of Votes for Warren", id=c("WP_NAME"), palette=MyPal, popup.vars=c("% of votes for Elizabeth Warren"="Percentage of Votes for Warren", "# of votes for Elizabeth Warren"="Votes for Elizabeth A. Warren", "# of votes for Geoff Diehl"="Votes for Geoff Diehl"),legend.show=FALSE)+
  tmap_options(max.categories = 5)

tmap_mode("view")
tmap_last()

setwd("C:/Users/User/Documents/GitHub/elections-map/elections-map")
tmap_save(map, filename="elections-map.html")
