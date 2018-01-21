# load all the packages needed
library(shiny)
library(shinyjs)
library(ggplot2)
library(dplyr)
library(rsconnect)


ui <- fluidPage(
  
  # App title
  titlePanel("Wine Shiny"),
  
  # Sidebar layout with input definitions
  sidebarLayout(
    sidebarPanel(
      img(src = "drink.jpg", width = "100%"),
      selectInput("countryInput", "Country",
                  choices = c("Argentina", "Australia", "Austria", "Chile",
                              "France", "Italy", "New Zealand", "Portugal",
                              "Spain", "US"),
                  selected = "France"),
      br(),
      colourInput("col", "Selected colour for histogram", "violetred4")
    ),
    
    # Main panel layout with output definitions
    mainPanel(
      tabsetPanel(
        tabPanel("Price", plotOutput("Price")),
        tabPanel("Points", plotOutput("Points")),
        tabPanel("Variety", plotOutput("Variety")))
    )
  )
)

dat <- read.csv("wine_filtered.csv", header=TRUE, sep=",")
dat$price_group = cut(dat$price,c(0,50,500,1000,1500,2000,2300))
levels(dat$price_group) = c("Very Cheap","Cheap","Inexpensive","Average","Expensive","Very Expensive")

# Define server for the app
server <- function(input, output) {
  
  filtered <- reactive({
    
    if(is.null(input$countryInput)) {
      return(NULL)
    }
    
    dat %>%
      filter(country == input$countryInput)
  })
  
  # create the output plots
  output$Price <- renderPlot({
    ggplot(filtered(), aes(x = country, y = price)) +
      geom_boxplot() +
      ggtitle("Boxplot of Price for Selected Country")
  })
  
  output$Points <- renderPlot({
    ggplot(filtered(), aes(x = points, y = price, col=price_group)) +
      geom_point() +
      ggtitle("Scatterplot of Price vs Points")
  })
  
  output$Variety <- renderPlot({
    ggplot(filtered(), aes(log(price))) +
      geom_histogram(binwidth=0.2, fill = input$col) +
      facet_wrap(~variety) +
      ggtitle("Distribution of log(price) by Variety")
  })
}

shinyApp(ui = ui, server = server)