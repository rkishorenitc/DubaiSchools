list.of.packages <- c("dplyr","ggplot2","leaflet","readxl","shinydashboard","rjson","DT","tidytext", "markdown")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(dplyr)
library(ggplot2)
library(leaflet)
library(readxl)
library(shinydashboard)
library(rjson)
library(DT)
library(tidytext)
library(markdown)
library(shiny)
library(osrm)
library(viridis)
library(sp)
library(sf)
library(leaflet.extras)

schools <- readRDS("./schools.rds")
schools$`Average Fees` = round(schools$`Average Fees`)
schools <- schools[!is.na(schools$rating),]
schools <- schools %>% filter(`Average Fees` > 0)
tms <- readRDS("./tms.rds")
tms <- tms[!is.na(tms$rating),]
if (schools$date[1] < Sys.Date()-15){
  #FETCH DATA
  schools <- read_excel("./cleaned.xlsx")
  schools <- na.omit(schools)
  #apikey <- "TO BE ADDED"
  info <- "name,rating,review,user_ratings_total"
  schools$rating <- NA
  schools$rating_no <- NA
  schools$f_1 <- NA
  schools$f_2 <- NA
  schools$f_3 <- NA
  schools$f_4 <- NA
  schools$f_5 <- NA
  for (i in 1:nrow(schools)){
    place_id <- schools$`Place ID`[i]
    url <- paste("https://maps.googleapis.com/maps/api/place/details/json?place_id=", place_id , "&fields=", info,"&key=",apikey, sep = "")
    data <- rjson::fromJSON(file = url)
    if (length(data$result) > 2){
      schools$rating[i] <- data$result$rating
      schools$rating_no[i] <- data$result$user_ratings_total
      if (data$result$user_ratings_total >= 5){
        schools$f_1[i] <- data$result$reviews[[1]]$text
        schools$f_2[i] <- data$result$reviews[[2]]$text
        schools$f_3[i] <- data$result$reviews[[3]]$text
        schools$f_4[i] <- data$result$reviews[[4]]$text
        schools$f_5[i] <- data$result$reviews[[5]]$text
      }
    }
  }
  schools$date <- Sys.Date()
  schools <- schools[!is.na(schools$rating),]
  saveRDS(schools, "schools.rds")
  tms_new <- schools[c(1,2,3,12,19)]
  if (max(tms$date) < Sys.Date()){
    tms <- rbind(tms, tms_new)
    saveRDS(tms, "tms.rds")
  }
}



