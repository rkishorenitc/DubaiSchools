# Use a fluid Bootstrap layout
navbarPage("Dubai School Decision Tool",
           #Row with input options
           fluidRow(
             column(3,
                    selectInput("selectedLocation", "Location Name:", c("All", c(sort(unique(schools$Location))))),
                    checkboxInput("isoselector", "Show Isochrones (loads slowly)", value = FALSE)
             ),
             column(3,
                    selectInput("selectedCurr", "Curriculum:", c("All", c(sort(unique(schools$Curriculum)))))
             ),
             column(3,
                    sliderInput("selectedRating", "Minimum Google Rating:", min = 0, max = 5, value = 2, step = 1)
             ),
             column(3,
                    sliderInput("selectedFees", "Maximum Annual Fees:", min = 5000, max = 110000, value = 110000, step = 10000)
             )
           ),
           tabPanel("Tool",
               tags$head(includeHTML(("google-analytics.html"))),

               fluidRow(
                 column(6, h5("Click on a school to learn more:"),
                        leafletOutput("map", height = 600),
                        hr(),
                        h4("Key Details:"),
                        tableOutput("details")),
                 column(6, fluidRow(
                   hr(),
                   h4("Google Reviews:"),
                   valueBoxOutput("rating", width = 6),
                   valueBoxOutput("reviews", width = 6)),
                   hr(),
                   h4("Rating Trend by Date:"),
                   plotOutput("timeseries"),
                   hr(),
                   h4("Top Reviews:"),
                   htmlOutput("topcomments")
                   ))),
           tabPanel("Listing",
                    dataTableOutput("schoolTable")),
           tabPanel("About",
                   includeMarkdown("about.md"))
)