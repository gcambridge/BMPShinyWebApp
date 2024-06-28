library(shiny)
# list of water quality parameters to plot
WQlist <- c("Select", "Conductivity", "Temperature", "Turbidity", "Depth", "Nitrate", "Total Suspended Solids", "Total Organic Carbon", "Dissolved Organic Carbon", "Soil Water Content", "Soil Conductivity", "Soil Temperature")
Towers <- c("Select", "1", "2")
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
      selectInput("towerID", "Select Tower ID", Towers),
      #Date time input
      textInput("fromDatetime", "From:", value = "YYYY-MM-DD HH:MM:SS" ),
      textInput("toDatetime", "To:", value = "YYYY-MM-DD HH:MM:SS" ),
      #1st Parameter
      selectInput("WQP1", "Water Quality Parameter 1:", WQlist), 
      #2nd Parameter
      selectInput("WQP2", "Water Quality Parameter 2:", WQlist),
      width = 3,
    ),
    
    mainPanel(
      width = 9,
      #Tabs
      tabsetPanel(
        tabPanel("Plot", plotOutput("VarPlot")),
        tabPanel("Table", tableOutput("VarTable")), 
        tabPanel("Camera Feed",imageOutput(""))
      )
    )
  ),
  
  
)

# Server Definition
server <- shinyServer(function(input, output, session) {

})


# End with call 
shinyApp(ui = ui, server = server)