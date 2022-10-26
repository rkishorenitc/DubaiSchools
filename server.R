# Define a server for the Shiny app

function(input, output, session) {
  #subsetting everything.
  
  data <- reactive({
    data <- schools
    if (input$selectedLocation != "All"){
      data <- data %>% filter(Location == input$selectedLocation)
    }
    if (input$selectedCurr != "All"){
      data <- data %>% filter(Curriculum == input$selectedCurr)
    }
    data <- data %>% filter(rating >= input$selectedRating)
    data <- data %>% filter(`Average Fees` <= input$selectedFees)
    return(data)
  })
  
  output$map <- renderLeaflet({
    
    data <- data()
    
    getColor <- function(data){
      sapply(data$rating, function(rating){
        if(rating >= 4){
          "green"
        } else if(rating >= 3){
          "orange"
        } else {
          "red"
        }
      })
    }

    icons <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      markerColor = getColor(data)
    )


    m <- leaflet(data = data) %>%
      addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE)) %>%
      addFullscreenControl() %>%
      addAwesomeMarkers(lng = ~Longitude,
                 lat = ~Latitude,
                 icon = icons,
                 layerId = ~Number,
                 popup = paste("School:", data$`School Name`, "<br>","Location:", data$Location)
      )
    m
  })
  

  
  click_data <- reactive({
    data <- data()
    site <- input$map_marker_click$id
    return(site)
  })
  
  
  
  keyfigures <- reactive({
    req(input$map_marker_click$id)
    pid <- click_data()
    data <- data()
    data <- data %>% filter(Number == pid)
    rating <- data$rating
    reviews <- data$rating_no
    keyfigures <- list("rating" = HTML(paste(format(rating, big.mark = " "))),
                       "reviews" = HTML(paste(format(reviews, big.mark = " "))))
    return(keyfigures)
  })
  
  sliderValues <- reactive({
    req(input$map_marker_click$id)
    pid <- click_data()
    data <- data()
    data <- data %>% filter(Number == pid)
    data.frame(
      Name = c("School Name",
               "Location",
               "Curriculum",
               "Year of Establishment",
               "DSIB Rating (if available)",
               "Latest Enrollments (if available)",
               "Average Annual Fees in AED (if available)"),
      Value = as.character(c(data$`School Name`,
                             data$`Location`,
                             data$`Curriculum`,
                             data$`Established Year`,
                             data$`DSIB Rating`,
                             data$`Enrollments`,
                             data$`Average Fees`)),
      stringsAsFactors = FALSE)
    
  })
  
  output$details <- renderTable({
    sliderValues()
  })
  
  output$rating <- renderValueBox({
    valueBox(
      keyfigures()$rating,
      subtitle = "User Rating",
      icon     = icon("star"),
      color    = "red",
      width    = NULL
    )
  })
  
  output$reviews <- renderValueBox({
    valueBox(
      keyfigures()$reviews,
      subtitle = "No. of User Reviews",
      icon     = icon("users"),
      color    = "red",
      width    = NULL
    )
  })
  
  output$schoolTable <- renderDataTable(datatable({
    schools <- data()
    schoolTable <- schools[c(2,4,7,8,9,10,11,12,13,19)]
    colnames(schoolTable) <- c("Name", "Location","Curriculum", "Established Year", "DSIB Rating", "Enrollments", "Average Fees", "Rating", "No. of Reviews", "Date of Update")
    schoolTable
  }))
  
  output$timeseries <- renderPlot({
    req(input$map_marker_click$id)
    pid <- click_data()
    data <- tms %>% filter(Number == pid)
    data <- data[c(4,5)]
    data$date <- as.Date(data$date, "%d/%m/%Y")
    ggplot( data = data, aes( date, rating )) + geom_line()
  })
  
  output$topcomments <- renderUI({
    req(input$map_marker_click$id)
    pid <- click_data()
    data <- data()
    data <- data %>% filter(Number == pid)
    data <- data[c(14,15,16,17,18)]
    data <- as.data.frame(t(data))
    text <- data$V1
    tags$ul(
      tags$li(tags$i(paste(data$V1[1])), style = "margin-bottom: 5px; color: #1D65A6; font-weight: bold"), 
      tags$li(tags$i(paste(data$V1[2])), style = "margin-bottom: 5px; color: #F1931B; font-weight: bold"), 
      tags$li(tags$i(paste(data$V1[3])), style = "margin-bottom: 5px; color: #1D65A6; font-weight: bold"), 
      tags$li(tags$i(paste(data$V1[4])), style = "margin-bottom: 5px; color: #F1931B; font-weight: bold"), 
      tags$li(tags$i(paste(data$V1[5])), style = "margin-bottom: 5px; color: #1D65A6; font-weight: bold"), 
      )
    })
  
  isochrone <- eventReactive(input$map_marker_click, {
    req(input$isoselector)
    pid <- click_data()
    data <- data()
    data <- data %>% filter(Number == pid)
    withProgress(message = 'Running Drive-Time Analysis.Please wait..',
                 isochrone <- osrmIsochrone(loc = c(data$Longitude, data$Latitude),
                                            breaks = c(10, 20, 30)) %>% st_as_sf())
    isochrone
  })
  
  observeEvent(input$map_marker_click, { 
    req(input$isoselector)
    steps = 3
    isochrone <- isochrone()
    pal <- colorFactor(viridis::plasma(nrow(isochrone), direction = -1), isochrone$max)
    leafletProxy("map") %>%
      clearShapes() %>% 
      #clearMarkers() %>%
      clearControls() %>%
      addPolygons(data = isochrone,
                  weight = .5, 
                  color = ~pal(max)
      ) %>%
      addLegend(data = isochrone,
                pal = pal, 
                values = ~max,
                title = 'Drive Time (min.)',
                opacity = 1) 
    #%>%
    #  addMarkers(lng = input$lon, input$lat) %>%
    #  setView(isoCoords()[['lon']], isoCoords()[['lat']], zoom = 9)
  })
  
  session$onSessionEnded(function() {
      stopApp()
  })
}