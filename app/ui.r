packages.used=c("leaflet","geosphere","shiny","shinydashboard","shinyjs","ggplot2","shinyWidgets","googleway")

# check packages that need to be installed.
packages.needed=setdiff(packages.used,
                        intersect(installed.packages()[,1],
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE)
}


library(shiny)
library(shinydashboard)
library(leaflet)
library(ggplot2)
library(shinyjs)
library(shinyWidgets)
library(googleway)

shinyUI(tagList(
  useShinyjs(),
  includeCSS("styles_new.css"),
  navbarPage(
    id='navbar',
    inverse=TRUE, collapsible=TRUE, fluid=TRUE,
    'Trip Advisor 2.0',
    
    tabPanel(title='Let us try',
             id='tab3',
             icon=icon('hand-o-right'),
             div(class='outer',
                 leafletOutput("map", width="100%",height="100%"),
                 
                 absolutePanel(div(id='title_content','STEP 1: Starting with Art'),
                               class='panel-default',
                               draggable=TRUE, fixed=TRUE,
                               top=100, left=60, bottom='auto', right='auto',
                               width=200, height=110,
                               selectInput('destination', width=200,
                                           div(id='label_content', 'What type do you like?'),
                                           choices=c('','Gallery','Museum','Theater','Library'), multiple=FALSE)),
                 
                 hidden(
                   absolutePanel(id="Sure",
                                 top=190, left=60, bottom='auto', right='auto',
                                 width=100, height=80,
                                 actionButton('button1','Confirm',width=100,
                                              icon=icon('hand-o-right')),
                                 actionButton('button2', 'Go back',width=100,
                                              icon=icon('hand-o-left'))
                   )),
                 
                 hidden(
                   absolutePanel(div(id='title_content2','STEP 2: Choose Food Destination'),
                                 class='panel-default',
                                 id='Resta',draggable=TRUE, fixed=TRUE,
                                 top=350, left=60, bottom='auto', right='auto',
                                 width=200, height=190,
                                 selectInput('type', div(id='label_content2','Categories:'),width=200,
                                             choices=c('Dessert','American','QuickMeal',
                                                       'Seafood','Italian','Asian','Mexician',
                                                       'Chinese','European','French','Other'), multiple=FALSE),
                                 selectInput('rank', div(id='label_content3','Ranking by:'),width=200,
                                             choices=c('by Grade','by Distance'), multiple=FALSE),
                                 actionButton('button3', 'Search ',width=100,
                                              icon=icon('hand-o-right'))
                   )
                 ),
                 
                 hidden(
                   absolutePanel(div(id='title_content4','Wanna Re-Start?'),id = "GoBack",
                                 class='panel-default', top=590, left=60, bottom='auto', right='auto',
                                 width=200, height=40,
                                 actionButton('button5', 'RESET ARTS', width=160,
                                              icon=icon('hand-o-left')),
                                 actionButton('button4', 'RESET RESTAURANTS', width=185,
                                              icon=icon('hand-o-left')))
                 ),
                 hidden(
                   absolutePanel(div(id='title_content4','Our Recommendation'),id = "StartRecom",
                                 class='panel-default', top=490, left=60, bottom='auto', right='auto',
                                 width=200, height=50,
                                 actionButton('button6', 'Not sure? Try this one!',width=250,icon=icon('hand-o-right'))
                                 
                   )
                 ),
                 hidden(
                   absolutePanel(div(id='title_content3','Our Recommendation'),
                                 class='panel-default',
                                 id='Recom', draggable=TRUE, fix=TRUE, 
                                 top=60, right=60, left='auto', bottom='auto',
                                 width=350, height=185,
                                 verbatimTextOutput('recom')
                                 
                   )
                 )
             )),
    tabPanel(title='Direction',
             icon=icon('question-circle-o'),
             div(class='outer',
                 google_mapOutput(outputId = "googlemap", width = "100%", height = "800px")
             )
    )
  ))
  
)
