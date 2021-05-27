library(shiny)

ui <- fluidPage(
    "Hello!"
)

server <- function(input, output, session) {
}

runApp(shinyApp(ui, server))
