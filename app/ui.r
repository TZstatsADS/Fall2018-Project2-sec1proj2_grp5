packages.used=c("leaflet","geosphere","shiny","shinydashboard","shinyjs","ggplot2","shinyWidgets","googleway","owmr")

# check packages that need to be installed.
packages.needed=setdiff(packages.used,
                        intersect(installed.packages()[,1],
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE)
}

library(owmr)
library(shiny)
library(shinydashboard)
library(leaflet)
library(ggplot2)
library(shinyjs)
library(shinyWidgets)
library(googleway)

api <- "d525a06f470a8117b7eef4106ec20011"
owmr_settings(api_key = api)

shinyUI(
  fluidPage(
  useShinyjs(),
  includeCSS("styles_new.css"),
  navbarPage(
    id='navbar',
    inverse=TRUE, collapsible=TRUE, fluid=TRUE,
    'Trip Advisor 2.0',
    tabPanel(title='Let us try',
             id='tab3',
             icon=icon('fas fa-google'),
             div(class='outer',
                 leafletOutput("map", width="100%",height="100%"),
                 
                 absolutePanel(div(id='title_content','STEP 1:Starting with art'),
                               class='panel-default',
                               draggable=TRUE, fixed=TRUE,
                               top=70, left=60, bottom='auto', right='auto',
                               width=320, height=110,
                               selectInput('destination', width=320,
                                           div(id='label_content', 'Choose one'),
                                           choices=c('','Gallery','Museum','Theater','Library'), multiple=FALSE)),
                 
                 hidden(
                   absolutePanel(id="Sure",
                                 top=150, left=60, bottom='auto', right='auto',
                                 width=100, height=80,
                                 actionButton('button1','Confirm',width=100,
                                              icon=icon('fas fa-check'))
                   )),
                 
                 hidden(
                   absolutePanel(div(id='title_content2','STEP 2: Finding Some Food'),
                                 class='panel-default',
                                 id='Resta',draggable=TRUE, fixed=TRUE,
                                 top=250, left=60, bottom='auto', right='auto',
                                 width=320, height=190,
                                 selectInput('type', div(id='label_content2','Categories:'),width=320,
                                             choices=c('American','Italian','Asian','Mexician',
                                                       'Chinese','European','Other'), multiple=FALSE),
                                 selectInput('rank', div(id='label_content3','Rank by:'),width=320,
                                             choices=c('by Yelp Star','by Distance'), multiple=FALSE),
                                 absolutePanel(id="SearchPanel",
                                               top=200, left=0,
                                               actionButton('button2', 'Search ',width=100,
                                                            icon=icon('fas fa-search'))
                                 )
                   )
                   
                 ),
                 hidden(
                   absolutePanel(div(id='title_content4','Wanna Re-Start?'),id = "GoBack",
                                 class='panel-default', top=570, left=60, bottom='auto', right='auto',
                                 width=320, height=40,
                                 absolutePanel(id="RESETPanel",
                                               top=50,left=0,
                                               actionButton('button3', 'Get Restart', width=180,
                                                            icon=icon('fas fa-step-backward'))
                                 )
                   )
                 ),
                 hidden(
                   absolutePanel(div(id='title_content4','Our Recommendation'),id = "StartRecom",
                                 class='panel-default', top=460, left=60, bottom='auto', right='auto',
                                 width=320, height=50,
                                 absolutePanel(id="TryPanel",
                                               top=60, left=0,
                                               actionButton('button4', 'Not sure? Try this one!',width=180,icon=icon('fas fa-thumbs-up'))
                                 )
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
             icon=icon('fas fa-car'),
             div(class='outer',
                 google_mapOutput(outputId = "googlemap", width = "100%", height = "800px"),
                 
                 absolutePanel(div(id='title_content','What is the weather like?'),
                               class='panel-default',
                               draggable=TRUE, fixed=TRUE,
                               top=100, left=60, bottom='auto', right='auto',
                               width=320, height=110,
                               print(res <- get_current("New York", units = "metric") %>%
                                                 flatten())["weather.description"], style="color:Black;font-family: Times New Roman;font-size: 120%;font-weight: bold;"),
                 
                 absolutePanel(div(id='title_content','How about the temperature?'),
                               class='panel-default',
                               draggable=TRUE, fixed=TRUE,
                               top=200, left=60, bottom='auto', right='auto',
                               width=320, height=110,
                               print(res <- get_current("New York", units = "metric") %>%
                                       flatten())["main.temp"], style="color:Black;font-family: Times New Roman;font-size: 120%;font-weight: bold;","Celsius"),
                 
                 absolutePanel(div(id='title_content','What is the humidity?'),
                               class='panel-default',
                               draggable=TRUE, fixed=TRUE,
                               top=300, left=60, bottom='auto', right='auto',
                               width=320, height=110,
                               print(res <- get_current("New York", units = "metric") %>%
                                       flatten())["main.humidity"], style="color:Black;font-family: Times New Roman;font-size: 120%;font-weight: bold;","%")
                 
               )
              ),
    
    tabPanel("About Us",
             fluidRow(
               br(),
               br(),
               br(),
               br(),
               br(),
               column(8, align="center", offset = 2, includeMarkdown("contact.md"))
             )

    )
  )
)
)

  



