library(shiny)

ui <- fluidPage(
    selectInput("in1", label = "Make a choice", choices = c("Option 1", "Option 2")),
    textOutput("out1")
)

server <- function(input, output, session) {
    output$out1 <- renderText({
        paste0("You have chosen: ", input$in1)
    })
}

runApp(shinyApp(ui, server))
