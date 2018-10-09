packages.used=c("leaflet","geosphere","shiny","dplyr","shinyjs")

# check packages that need to be installed.
packages.needed=setdiff(packages.used,
                        intersect(installed.packages()[,1],
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE)
}


library(dplyr)
library(leaflet)
library(shiny)
library(shinyjs)

museum<-na.omit(read.csv("../data/museums.csv"))
theatre<-read.csv("../data/theatre.csv")
gallery<-read.csv("../data/Gallery.csv")
library<-read.csv("../data/library.csv")
restaurant<- read.csv("../data/restaurant_new.csv")
icon_museum<-icons(iconUrl = 'icon_museum.png',iconHeight = 15, iconWidth = 15)
icon_theatre<-icons(iconUrl = 'icon_theatre.png', iconHeight = 18, iconWidth = 18)
icon_library<-icons(iconUrl = 'icon_library.png', iconHeight = 18, iconWidth = 18)
icon_gallery<-icons(iconUrl = 'icon_gallery.png', iconHeight = 18, iconWidth = 18)
icon_rest<-icons(iconUrl =  'icon_rest.png', iconHeight=25, iconWidth = 25)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
   globallng = -73.93
   globallat = 40.77
   startName =""
   deslng = -73.91
   deslat = 40.72
   
   output$map<-renderLeaflet({
     leaflet() %>% setView(lng=-73.93, lat=40.77, zoom=10) %>% addProviderTiles('Esri.WorldTopoMap')
   })
   set_key("AIzaSyDTIop6J0QlXc8RRbj5M3kAVyOy3zyXzTE")
   
   observeEvent(input$destination, {
     if(''==input$destination){
       leafletProxy('map') %>% setView(lng=-73.93, lat=40.77, zoom=12)
     }
     else if('Museum'==input$destination){
       
       leafletProxy('map') %>% clearMarkerClusters() %>% setView(lng=-73.93, lat=40.77, zoom=12) %>% 
         addMarkers(museum$longtitude, 
                    museum$latitude, icon=icon_museum,
                    clusterOptions=markerClusterOptions(),
                    popup=paste('Name:',museum$NAME, '<br/>',
                                'Tel:', museum$TEL, '<br/>',
                                'Zip:', museum$ZIP, '<br/>',
                                'Website:', a(museum$URL, href=museum$URL), '<br/>', 
                                'Add:', museum$ADRESS1, '<br/>'
                                )
                   
                    )
     }
     else if('Theater'==input$destination)
     {
       leafletProxy('map') %>% clearMarkerClusters() %>% setView(lng=-73.93, lat=40.77, zoom=12) %>% 
         addMarkers(theatre$longtitude,
                    theatre$latitude, icon=icon_theatre,
                    clusterOptions=markerClusterOptions(),
                    popup=paste('Name:', theatre$NAME, '<br/>',
                                'Tel:', theatre$TEL, '<br/>',
                                'Zip:', theatre$ZIP, '<br/>',
                                'Website:', a(theatre$URL, href=theatre$URL), '<br/>',
                                'Add:', theatre$ADDRESS1, '<br/>'))
     }
     else if ('Gallery'==input$destination)
     {
       leafletProxy('map') %>% clearMarkerClusters() %>% setView(lng=-73.93, lat=40.77, zoom=12) %>% 
         addMarkers(gallery$LON,
                    gallery$LAT, icon=icon_gallery,
                    clusterOptions=markerClusterOptions(),
                    popup=paste('Name:', gallery$NAME, '<br/>',
                                'Tel:', gallery$TEL, '<br/>',
                                'Zip:', gallery$ZIP, '<br/>',
                                'Website:', a(gallery$URL, href=gallery$URL), '<br/>',
                                'Add:', gallery$ADDRESS1, '<br/>'))
     }
     else {
       leafletProxy('map') %>% clearMarkerClusters() %>% setView(lng=-73.93, lat=40.77, zoom=12) %>% 
         addMarkers(library$LON,
                    library$LAT, icon=icon_library,
                    popup=paste('Name:', library$NAME, '<br/>',
                                'Zip:', library$ZIP, '<br/>',
                                'Website:', a(library$URL, href=library$URL), '<br/>',
                                'Add:', library$ADDRESS1, '<br/>'),
                    clusterOptions=markerClusterOptions())
     }
    
   })
   
   observe({
     click<- input$map_marker_click
     if(is.null(click))
       return() 
     ## use click to access the zoom and set the view according this marker
     globallng <<- click$lng
     print(globallng)
     globallat <<- click$lat
     print(globallat)
     leafletProxy('map') %>% setView(lng=click$lng, 
                                     lat=click$lat,
                                     zoom=15)
   })
   
   observeEvent(input$button2,{
     leafletProxy('map') %>% setView(lng=-73.93, lat=40.77, zoom=12)
   })
   
     observeEvent(input$map_marker_click, {
       show('Sure')
     })
     
   
     observeEvent(input$button1, {
       show('Resta')
     })
     
     observeEvent(input$button3,{
       show('StartRecom')
     })
     
     observeEvent(input$button6,{
       show('Recom')
     })
     
     observeEvent(input$button3,{
       show('GoBack')
     })
     
     observeEvent(input$button3, {
       click<- input$map_marker_click
       type<- input$type
       rank<- input$rank
       if(is.null(type))
         return()
       lng<- click$lng
       lat<- click$lat
       if(rank=='by Distance'){
         
         add_to_df<- reactive({
           rest <-  restaurant %>% dplyr::filter(TYPE==type) %>% 
             mutate(dist = sqrt((LON-lng)^2 + (LAT-lat)^2)) %>% arrange(dist)
           rest
         })
         
         new_df<- reactive({
           all_rest <- add_to_df()
           top6<- head(all_rest,6)
           top6
         })
         
         dist_column<- reactive({
           avail_rest<- new_df()
           dist<- avail_rest$dist
           dist
         })
         
         if(all(dist_column()>0.05)){
           output$recom<- renderText('Oops! There is no available restaurant around you!')}
         else{leafletProxy('map',data = new_df())  %>% addMarkers(lng = ~LON, lat = ~LAT, icon=icon_rest,
                                                                  popup=~paste('Name:', NAME, '<br/>',
                                                                               'Tel:', TEL, '<br/>',
                                                                               'Zip:', ZIP, '<br/>',
                                                                               'Add:', ADDRESS, '<br/>',
                                                                               'Yelp.Star:', YELP.STAR, '<br/>'))
           output$recom<- renderText({
             recom_rest<-new_df() 
             deslng = recom_rest[1,]$LON
             print(deslng)
             deslat = recom_rest[1,]$LAT
             print(deslat)
             df <- google_directions(origin = c(globallat, globallng),
                                     destination = c(deslat, deslng),
                                     mode = "walking",
                                     simplify = TRUE)
             print(df)
             df_routes <- data.frame(polyline = direction_polyline(df)) 
             dfdata <- structure(list(lat = c(globallat, deslat), lon = c(globallng, deslng)), .Names = c("lat","lon"), row.names = 379:380, class = "data.frame")
             
             output$googlemap <- renderGoogle_map({
               
               google_map(location = c(40.77, -73.93), 
                          data = dfdata,
                          zoom = 12,
                          height = "800px")  %>% 
                 add_polylines(data = df_routes, polyline = "polyline") %>% 
                 add_markers()
               
             })
             paste('Name:', recom_rest[1,]$NAME,'\n',
                   'Tel:', recom_rest[1,]$TEL,'\n',
                   'Zip:', recom_rest[1,]$ZIP,'\n',
                   'Add:', recom_rest[1,]$ADDRESS,'\n',
                   'Yelp.Star:', recom_rest[1,]$YELP.STAR)
           })
         }
         
       }
       else{
         
         add_to_df<- reactive({
           rest<- restaurant %>% dplyr::filter(TYPE==type) %>% 
             mutate(dist = sqrt((LON-lng)^2 + (LAT-lat)^2)) %>% arrange(dist) 
           rest
         })
         
         new_df<- reactive({
           all_rest<-add_to_df()
           top15<-head(all_rest, 15) %>% arrange(desc(YELP.STAR))
           top6<- head(top15, 6)
           top6
         })
         
         dist_column<- reactive({
           avail_rest<-new_df()
           dist<- avail_rest$dist
           dist
         })
         
         if(all(dist_column()>0.05)){
           output$recom<- renderText('Oops! There is no available restaurant around you!')}
         else{leafletProxy('map',data = new_df())  %>% addMarkers(lng = ~LON, lat = ~LAT, icon=icon_rest,
                                                                  popup=~paste('Name:', NAME, '<br/>',
                                                                               'Tel:', TEL, '<br/>',
                                                                               'Zip:', ZIP, '<br/>',
                                                                               'Add:', ADDRESS, '<br/>',
                                                                               'Yelp.Star:', YELP.STAR, '<br/>'))
           output$recom<- renderText({
             recom_rest<-new_df() 
             deslng = recom_rest[1,]$LON
             print(deslng)
             deslat = recom_rest[1,]$LAT
             print(deslat)
             print(globallng)
             print(globallat)
             df <- google_directions(origin = c(globallat, globallng),
                                     destination = c(deslat, deslng),
                                     mode = "walking",
                                     simplify = TRUE)
             print(df)
             
             
             df_routes <- data.frame(polyline = direction_polyline(df)) 
             dfdata <- structure(list(lat = c(globallat, deslat), lon = c(globallng, deslng)), .Names = c("lat","lon"), row.names = 379:380, class = "data.frame")
             
             output$googlemap <- renderGoogle_map({
               
               google_map(location = c(40.77, -73.93), 
                          data = dfdata,
                          zoom = 12,
                          height = "800px")  %>% 
                 add_polylines(data = df_routes, polyline = "polyline")  %>% 
                 add_markers()
               
             })
             paste('Name:', recom_rest[1,]$NAME,'\n',
                   'Tel:', recom_rest[1,]$TEL,'\n',
                   'Zip:', recom_rest[1,]$ZIP,'\n',
                   'Add:', recom_rest[1,]$ADDRESS,'\n',
                   'Yelp.Star:', recom_rest[1,]$YELP.STAR)
           })
         }
       }
     })
     
     observeEvent(input$button4,{
       leafletProxy('map') %>% clearMarkers()
       hide('Recom')
       hide("GoBack")
     })
     
     observeEvent(input$button5,{
       leafletProxy('map') %>% clearMarkers()
       hide("StartRecom")
       hide('Recom')
       hide('Resta')
       hide('Sure')
       hide("GoBack")
     })
})
