library(shiny)
library(dplyr)
library(ggplot2)

## some made up data
track_data <- tibble(lon = seq(60, 90, by = 1) + rnorm(31, sd = 0.1),
                lat = -55 - 10 * sin((lon - 60)/30*pi/2),
                speed = runif(31, min = 0.5, max = 3.0),
                depth = runif(31, min = -50, max = -5))

survey_data <- tibble(lon = runif(25, min = 100, max = 120),
                lat = runif(25, min = -55, max = -45),
                biomass = runif(25, min = 0.01, max = 2.0))

ui <- fluidPage(
    selectInput("data_choice", label = "Choose data:", choices = c("Track", "Survey")),
    selectInput("colour_choice", label = "Choose colour var:", choices = NULL),
    plotOutput("plot1")
)

server <- function(input, output, session) {
    ## data

    ## colour choices

    ## plot
}

runApp(shinyApp(ui, server))
