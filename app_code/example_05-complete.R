library(shiny)
library(shinyjs)
library(dplyr)
library(ggplot2)
library(ggiraph)
library(leaflet)

## some made up data
track_data <- tibble(lon = seq(60, 90, by = 1) + rnorm(31, sd = 0.1),
                lat = -55 - 10 * sin((lon - 60)/30*pi/2),
                speed = runif(31, min = 0.5, max = 3.0),
                depth = runif(31, min = -50, max = -5))

survey_data <- tibble(lon = runif(25, min = 100, max = 120),
                lat = runif(25, min = -55, max = -45),
                biomass = runif(25, min = 0.01, max = 2.0))

ui <- fluidPage(theme = shinythemes::shinytheme("simplex"),
                useShinyjs(),
                tags$h1("My amazing Shiny app"),
                sidebarLayout(
                    sidebarPanel(selectInput("data_choice", label = "Choose data:", choices = c("Track", "Survey")),
                                 selectInput("colour_choice", label = "Choose colour var:", choices = NULL),
                                 downloadButton("download", "Download data")
                                 ),
                    mainPanel(
                        tabsetPanel(
                            tabPanel("Plot and table",
                                     girafeOutput("plot1"),
                                     leafletOutput("map1"),
                                     DT::dataTableOutput("table1")),
                            tabPanel("Data summary",
                                     verbatimTextOutput("text1"))
                        )
                    )
                )
)

server <- function(input, output, session) {
    mydata <- reactive({
        req(input$data_choice) ## require a "truthy" value here
        if (input$data_choice == "Track") {
            track_data
        } else {
            survey_data
        }
    })

    observe({
        req(mydata())
        chc <- names(mydata())
        isolate(sel <- input$colour_choice)
        if (!sel %in% chc) sel <- NULL
        updateSelectInput(session, inputId = "colour_choice", choices = chc, selected = sel)
    })

    output$text1 <- renderPrint(summary(mydata()))

    output$table1 <- DT::renderDataTable({
        DT::datatable(mydata(), filter = "top")
    })

    observe({
        req(input$data_choice)
        if (input$data_choice == "Track") {
            shinyjs::show("plot1")
            shinyjs::hide("map1")
        } else {
            shinyjs::hide("plot1")
            shinyjs::show("map1")
        }
    })

    plotrows <- reactive({
        idx <- input$table1_rows_all
        if (is.null(idx) || length(idx) < 1) idx <- seq_len(nrow(mydata()))
        idx
    })

    output$plot1 <- renderGirafe({
        if (length(input$data_choice) < 0 || input$data_choice != "Track") return(NULL)
        req(mydata(), input$colour_choice)
        req(input$colour_choice %in% names(mydata()))

        p <- ggplot(mydata()[plotrows(), ],
               aes_string(x = "lon", y = "lat", colour = input$colour_choice)) +
            geom_point_interactive(aes_string(tooltip = input$colour_choice)) + theme_bw()

        if (length(input$table1_rows_selected) > 0) {
            p <- p + geom_point(data = mydata()[input$table1_rows_selected, ], color = "red", size = 3)
        }

        girafe_options(girafe(ggobj = p), opts_zoom(max = 5))##opts_selection(type = "multiple"), )
    })

    output$map1 <- renderLeaflet({
        req(mydata())
        if (length(input$data_choice) < 0 || input$data_choice != "Survey") return(NULL)

        m <- leaflet() %>%
            addProviderTiles("Esri.WorldImagery") %>%
            addCircleMarkers(lng = mydata()$lon[plotrows()], lat = mydata()$lat[plotrows()])

        if (length(input$table1_rows_selected) > 0) {
            m <- m %>% addCircleMarkers(lng = mydata()$lon[input$table1_rows_selected], lat = mydata()$lat[input$table1_rows_selected], color = "red")
        }

        m
    })

    output$download <- downloadHandler(filename = "mydata.csv",
                                       content = function(f) write.csv(mydata(), file = f))

}

runApp(shinyApp(ui, server))
