

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(ggridges)
library(ggplot2)
library(plyr)
library(dplyr)
library(plotly)
library(viridis)
library(hrbrthemes)
# source("helpers.R")
COVID_DATA <- read.csv("data/COVID_DATA.csv", header = T, sep = ',')

state_list <- levels(COVID_DATA$state)

# User interface ----
ui <- fluidPage(theme = shinytheme("flatly"),
                tags$a(href=('https://covidtracking.com/'),
                       tags$img(src = "Covid Image.png")),
                titlePanel("Current Status of COVID-19 in the U.S."),
                
                sidebarLayout(
                  sidebarPanel(
                    helpText("Change Graph:"),
                    
                    selectInput(
                      "var",
                      label = "Choose a Variable to display",
                      choices = c("positive", "death"),
                      selected = "positive"),
                    sliderInput(
                      "slider",
                      label = "Top N States by Total Tests Given",
                      min = 5, max = 50, value = 10
                    ),
                    pickerInput(
                      "state_filter1",
                      label = "State Filter - Bubble Graph",
                      choices = state_list,
                      selected = state_list,
                      options = list('actions-box' = TRUE),
                      multiple = T
                    ),
                    pickerInput(
                      "state_filter2",
                      label = "State Filter - Time Series",
                      choices = state_list,
                      selected = "VA"
                    )),
                  
                  # Main panel for displaying outputs ----
                  mainPanel(
                    
                    # Output: Tabset w/ plot, summary, and table ----
                    tabsetPanel(type = "tabs",
                                tabPanel(h2("Death Rate"),
                                         plotlyOutput("plot",height="800px")
                                         ),
                    tabPanel(h2("Time Series"),
                             br(),
                             plotlyOutput("plot2"))
                    )
                  )
                )
)

# Server logic ----

server <- function(input, output) {
  
  # COVID_DATA <- read.csv("data/COVID_DATA2.csv", header = T, sep = ',')
  COVID_DATA2 <- reactive({
    COVID_DATA %>%  
      dplyr::filter(state == input$state_filter1,Most_Recent_Date=='Most_Recent') %>% 
      dplyr::group_by(state) %>% 
      dplyr::summarise(positive=sum(positive),total=sum(total),death=sum(death),hospitalized=sum(hospitalized,na.rm=T)) %>% 
      dplyr::top_n(input$slider,total)
    })
  
  COVID_DATA3 <- reactive({
    COVID_DATA %>%  
      filter(state == input$state_filter2)})
  
  output$plot <- renderPlotly({
    
    data <- switch(
      input$var,
      "positive" = COVID_DATA2()$positive,
      "death" = COVID_DATA2()$death
    )
    
    ggplotly(
     ggplot(COVID_DATA2(),
            aes(x = state, y = death/positive, size = total, color = log(total))) +
        geom_point() +
        ggtitle(paste0("Death Rates for Top ",input$slider," States by Total Tests Given","\n Hover over line to view tooltip"))+
        scale_size(name = "Total Tests") +
        scale_color_viridis(guide = FALSE)+
        theme_ipsum()+
        theme(axis.text.x = element_text(hjust = 1, size = 8),
              plot.title = element_text(color="#475B63", size=14, face="bold.italic")
          #,legend.position = "none"
          )
    )
    
  })
  
  output$plot2 <- renderPlotly({
    
    data <- switch(
      input$var,
      "positive" = COVID_DATA3()$positive,
      "death" = COVID_DATA3()$death
    )
    
    ggplotly(
        ggplot(COVID_DATA3(),
           aes(x = as.Date(date_COVID),y = data )) +
      ggtitle(paste0("Daily ",input$var,"s for: ",input$state_filter2,"\n Hover over line to view tooltip"))+
      geom_line( color = "#475B63", size = 1.75) +
      #geom_text(label = data, nudge_y = 0.5, check_overlap = T) +
      scale_y_continuous(trans='log10')+
      labs(y = "Positive Cases", x = "Date")+
      #theme_ipsum()+
      theme(axis.text.x=element_text(angle=60,hjust=1),
            plot.title = element_text(color="#475B63", size=14, face="bold.italic"))
      )
    
    
  })
  
}


# Run app ----
shinyApp(ui, server)


