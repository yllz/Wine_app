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
      selectInput("countryInput", h4("Select Country"),
                  choices = c("Argentina", "Australia", "Austria", "Chile",
                              "France", "Italy", "New Zealand", "Portugal",
                              "Spain", "US", "Germany", "South Africa",
                              "Greece", "Israel", "Hungary"),
                  selected = "France"),
      br(),
      uiOutput("secondSelection"),
      br(),
      colourInput("col", "Selected colour for histogram", "violetred4"),
      br(),
      helpText("Note: The range of price is large from 4 to 2300,",
               "so I take a log transformation when creating the faceted plots.")
    ),
    
    # Main panel layout with output definitions
    mainPanel(
      plotOutput('Price'),
      br(),
      plotOutput('Points'),
      br(),
      plotOutput('Variety')
    )
  )
)

dat <- read.csv("wine_filtered.csv", header=TRUE, sep=",")
dat$price_group = cut(dat$price,c(0,50,500,1000,1500,2000,2300))
levels(dat$price_group) = c("0-50","50-500","500-1000","1000-1500","1500-2000","2000-2300")

# Define server for the app
server <- function(input, output) {
  
  filtered <- reactive({
    
    if(is.null(input$countryInput)) {
      return(NULL)
    }
    
    dat %>%
      filter(country == input$countryInput, province %in% input$Province)
  })
  
  var <- reactive({
    switch(input$countryInput,
           "Argentina" = as.list(dat %>% filter(country == "Argentina") %>% distinct(province))$province,
           "Australia" = as.list(dat %>% filter(country == "Australia") %>% distinct(province))$province,
           "Austria" = as.list(dat %>% filter(country == "Austria") %>% distinct(province))$province,
           "Chile" = as.list(dat %>% filter(country == "Chile") %>% distinct(province))$province,
           "France" = as.list(dat %>% filter(country == "France") %>% distinct(province))$province,
           "Italy" = as.list(dat %>% filter(country == "Italy") %>% distinct(province))$province,
           "New Zealand" = as.list(dat %>% filter(country == "New Zealand") %>% distinct(province))$province,
           "Portugal" = as.list(dat %>% filter(country == "Portugal") %>% distinct(province))$province,
           "Spain" = as.list(dat %>% filter(country == "Spain") %>% distinct(province))$province,
           "US" = as.list(dat %>% filter(country == "US") %>% distinct(province))$province,
           "Germany" = as.list(dat %>% filter(country == "Germany") %>% distinct(province))$province,
           "South Africa" = as.list(dat %>% filter(country == "South Africa") %>% distinct(province))$province,
           "Greece" = as.list(dat %>% filter(country == "Greece") %>% distinct(province))$province,
           "Israel" = as.list(dat %>% filter(country == "Israel") %>% distinct(province))$province,
           "Hungary" = as.list(dat %>% filter(country == "Hungary") %>% distinct(province))$province)
    })
  
  output$secondSelection <- renderUI({
    checkboxGroupInput("Province", h4("Select Provinces"), choices = var(), selected = head(var(),2))
    
  })
  
  # create the output plots
  output$Price <- renderPlot({
    ggplot(filtered(), aes(price)) +
      geom_density() +
      ggtitle("Density Plot of Price for Selected District")
  })
  
  output$Points <- renderPlot({
    ggplot(filtered(), aes(x = points, y = price, col=price_group)) +
      geom_point() +
      ggtitle("Scatterplot of Price vs. Points")
  })
  
  output$Variety <- renderPlot({
    ggplot(filtered(), aes(log(price))) +
      geom_histogram(binwidth=0.1, fill = input$col) +
      facet_wrap(~variety) +
      ggtitle("Distribution of log(price) by Variety")
  })
}

shinyApp(ui = ui, server = server)