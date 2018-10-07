library(shiny)
library(shinydashboard)
library(googleway)
library(ggmap)

devtools::install_github("dkahle/ggmap")
register_google(key = 'AIzaSyARO9UpPhYPi5HAXWngJ3C4z2zTmdT09mc')

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    textInput(inputId = "origin", label = "Origin"),
    textInput(inputId = "destination", label = "Destination"),
    actionButton(inputId = "getRoute", label = "Get Rotue"),
    google_mapOutput("myMap")
  )
)

server <- function(input, output){
  
  api_key <- "AIzaSyARO9UpPhYPi5HAXWngJ3C4z2zTmdT09mc"
  map_key <- "AIzaSyARO9UpPhYPi5HAXWngJ3C4z2zTmdT09mc"
  
  
  df_route <- eventReactive(input$getRoute,{
    
    print("getting route")
    
    o <- input$origin
    d <- input$destination
    
    return(data.frame(origin = o, destination = d, stringsAsFactors = F))
  })
  
  
  output$myMap <- renderGoogle_map({
    
    df <- df_route()
    print(df)
    if(df$origin == "" | df$destination == "")
      return()
    
    res <- google_directions(
      key = api_key
      , origin = df$origin
      , destination = df$destination, 
      mode = 'transit'
    )
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    google_map(key = map_key ) %>%
      add_polylines(data = df_route, polyline = "route")
  })
}

shinyApp(ui, server) 
  

####  
  
  
library(googleway)

api_key <- "your_directions_api_key"
map_key <- "your_maps_api_key"

## set up a data.frame of locations
## can also use 'lat/lon' coordinates as the origin/destination
df_locations <- data.frame(
  origin = c("Melbourne, Australia", "Sydney, Australia")
  , destination = c("Sydney, Australia", "Brisbane, Australia")
  , stringsAsFactors = F
)

## loop over each pair of locations, and extract the polyline from the result
lst_directions <- apply(df_locations, 1, function(x){
  res <- google_directions(
    key = api_key
    , origin = x[['origin']]
    , destination = x[['destination']]
  )
  
  df_result <- data.frame(
    origin = x[['origin']]
    , destination = x[['destination']]
    , route = res$routes$overview_polyline$points
  )
  return(df_result)
})

## convert the results to a data.frame
df_directions <- do.call(rbind, lst_directions)
  
  
  
  
## plot the map
google_map(key = map_key ) %>%
  add_polylines(data = df_directions, polyline = "route")
  
?gmap  
  
  
  