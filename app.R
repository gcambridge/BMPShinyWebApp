library(shiny)
library(ggplot2)
library(lubridate)
library(haven)
library(dplyr)

# list of water quality parameters to plot
WQlist <- list("TIMESTAMP", "Conductivity", "Temperature", "Turbidity", "Depth", 
            "TSSeq", "TOCeq","DOCeq","NO3eq","Temp_spv3")

#List of monitoring towers
Towers <- c("Select", "1", "2")

#Load in data file - seems like it can be from a URL
Tx15 <- read.csv("BMPTripod1_Min_15.dat")
Tx15$TIMESTAMP <- ymd_hms(Tx15$TIMESTAMP)

#CalData <- read.csv("TestCalData.csv")

Tx15flt <- Tx15

# User Interface Definition 
ui <- fluidPage(
  
  #Styling for sidebar
  tags$style(HTML("
    .shiny-input-container  {
      background-color: #91b0c9;
      color: white;
      padding: 5% 10%;
      border-radius: 10px;
    }")),
  
  titlePanel("StREAM Lab BDA BMP"),
  
  sidebarLayout(
    
    sidebarPanel(
      #Tower Selector
      radioButtons("towerID", "Select Tower:",
                 c("Tower 1" = "t1" ,
                  "Tower 2" = "t2")),
      
      #Date Time Selector
      textInput("fromDate", "From:", value = "2024-02-02 00:00:00" ),
      textInput("toDate", "To:", value = "2024-05-01 00:00:00" ),
         
      #1st Parameter
      selectInput("WQP1", "Water Quality Parameter 1 (x):", WQlist), 
      #2nd Parameter
      selectInput("WQP2", "Water Quality Parameter 2 (Y):", WQlist),
      actionButton("plotParams", "Plot"),
      width = 2,
    ),
    
    mainPanel(
      width = 9,
      #Tabs
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot")),
      
        
        tabPanel("Table", tableOutput("VarTable")), 
        tabPanel("Camera Feed",imageOutput("")), 
        tabPanel("Calibration Data", 
                 fluidRow(
                   column(width = 4,
                       fileInput("file", "Calibration File:")),
                        actionButton("plotCalib", "Plot Calibration Data"),
                   ),
                  plotOutput("calib"))
      )
    )
  ),
  
  
)

# Server Definition
server <- shinyServer(function(input, output, session) {
  
#Plot two selected variables
  parameterPlot <- reactive({
    Tx15flt <- filter(Tx15, between(Tx15$TIMESTAMP,
                                    ymd_hms(input$fromDate),
                                    ymd_hms(input$toDate)
    ))
    
    Tx15c <- Tx15flt[ ,c(input$WQP1,input$WQP2)]
    
    ggplot() +
      geom_line(data = Tx15c, aes(x=Tx15c[,1],y=Tx15c[,2])) +
      labs(title = "Plot", x=colnames(Tx15c)[1], y=colnames(Tx15c)[2]) +
      theme_classic()
    
  })|> 
    bindEvent(input$plotParams, ignoreNULL = FALSE)
   
  output$plot <- renderPlot({
    parameterPlot()
    
  }) 
    
 #plot calibration plot
  calibratePlot <- reactive({
    #make this a function?
    Tx15flt <- filter(Tx15, between(Tx15$TIMESTAMP, 
                                    ymd_hms(input$fromDate),
                                    ymd_hms(input$toDate)
    )) 
    
    # file <- input$Calfile
    # Calfile <- read.csv(file$datapath, header = input$header)
    # print(Calfile)
    # Calfile$TIMESTAMP <- ymd_hms(Calfile$TIMESTAMP)
    # CalDataflt <- Calfile
    
    # CalDataflt <- filter(Calfile, between(Calfile$TIMESTAMP, 
    #                     ymd_hms(input$fromDate),
    #                     ymd_hms(input$toDate)
    #                   ))
    ggplot() +
      geom_line(data = Tx15flt, aes(x=TIMESTAMP, y = NO3eq)) +
      #geom_line(data = CalDataflt, aes(x=TIMESTAMP, y = NO3conc), color = "red") +
    
      labs(title = "Nitrate Calibration Data at Station X") +
      theme_classic()
    
                })|> 
    bindEvent(input$plotCalib, ignoreNULL = FALSE)
 
  
  
  
  
  output$calib <- renderPlot({
    calibratePlot()
    
    })
})
  
# End with call 
shinyApp(ui = ui, server = server)