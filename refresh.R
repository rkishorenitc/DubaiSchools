schools <- read_excel("./cleaned.xlsx")
schools <- na.omit(schools)
#apikey <- "TO BE ADDED"
info <- "name,rating,review,user_ratings_total"
schools$rating <- 0
schools$rating_no <- 0
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
saveRDS(schools, "schools.rds")
tms <- schools[c(1,2,3,12,19)]
saveRDS(tms, "tms.rds")
