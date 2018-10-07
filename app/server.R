
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

museum<-na.omit(read.csv("C:/Users/cjsly/Documents/GitHub/Fall2017-project2-grp5/data/museums.csv"))
theatre<-read.csv('C:/Users/cjsly/Documents/GitHub/Fall2017-project2-grp5/data/theatre.csv')
gallery<-read.csv("C:/Users/cjsly/Documents/GitHub/Fall2017-project2-grp5/data/Gallery.csv")
library<-read.csv('C:/Users/cjsly/Documents/GitHub/Fall2017-project2-grp5/data/library.csv')

restaurant<- read.csv('C:/Users/cjsly/Documents/GitHub/Fall2017-project2-grp5/data/restaurant_new.csv')
icon_museum<-icons(iconUrl = 'icon_museum.png',iconHeight = 15, iconWidth = 15)
icon_theatre<-icons(iconUrl = 'icon_theatre.png', iconHeight = 18, iconWidth = 18)

icon_rest<-icons(iconUrl =  'icon_rest.png', iconHeight=25, iconWidth = 25)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  

   output$map<-renderLeaflet({
     leaflet() %>% setView(lng=-73.93, lat=40.77, zoom=10) %>% addTiles()
   })
  
   observeEvent(input$destination, {
     if('Museum'==input$destination){
       
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
                    gallery$LAT, icon=icon_theatre,
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
                    library$LAT, icon=icon_theatre,
                    clusterOptions=markerClusterOptions(),
                    popup=paste('Name:', library$NAME, '<br/>',
                                'Zip:', library$ZIP, '<br/>',
                                'Website:', a(library$URL, href=library$URL), '<br/>',
                                'Add:', library$ADDRESS1, '<br/>'))
     }
    
   })
   
   observe({
     click<- input$map_marker_click
     if(is.null(click))
       return() 
     ## use click to access the zoom and set the view according this marker
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
       show('Recom')
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
     })
     
     observeEvent(input$button5,{
       leafletProxy('map') %>% clearMarkers()
       hide('Recom')
       hide('Resta')
       hide('Sure')
     })
})








