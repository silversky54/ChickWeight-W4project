#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

library(Rcpp)
library(shiny)
library(ggplot2)
#library(plotly)
library(dplyr)

# UI to select the input the type of Diet and growth time of a chicken to estimate/predict
# the weight of the chicken.
shinyUI(
  fluidPage(
  
    # Application title 
    titlePanel(h1("Chick Weight and Diet", align="center")),
  
    # Sidebar with a slider input to select the time in days of chicken life  
    sidebarLayout(
      sidebarPanel(
        h4(span("Model Inputs", style="color:blue")),
        p("Select Number of days and diet to predict average chick weight of a clutch"),
        sliderInput("Tdays","Number of days:", min = 1, max = 21, value = 15),
        selectInput("Diet", "Chicken Food Diet:", choices=c(1,2,3,4), selected=1),
        actionButton("reset", "Reset Inputs"),
        br(),
        br(),
        span(h4("Plot Controls"), style="color:blue"),
        p("Select diet to plot data points and regression line."),
        checkboxGroupInput("DietLine", label="Plot Diet:", 
                           choices=c(1,2,3,4), 
                           selected=c(1,2,3,4),
                           inline = T),
        actionButton("selectall", "Select All"),
        actionButton("clearall", "Clear All")
      ), #End of sidebar Panel
    
      # Show a plot of the generated distribution
      mainPanel(
        p("The Following plot represents the growth over time of 4 samples of chicks each group fed with 
          a different diet. A model was fitted and plotted with 4 regression lines, one per each
          diet. It attemps to predict the average (mean) weight of a clutch of chicks after a period 
          of time using one of the 4 diets."),
        p(HTML("You can use the controls on the left to adjust the inputs of the model to predict the 
          average weight of a clutch or to add or remove the data points and regression lines in the 
          plot. <br> 
          To adjust the model inputs:<br>
          <ul>
            <li>Use the slide bar to adjust the number of days.</li> 
            <li>Use the drop down manu to select the diet. </li>
          </ul>
          To add/remove items from the plot: <br>
          <ul>
            <li>Use the checkboxes for each diet.</li>
          </ul>")),
        plotOutput("CWPlot1", width = 700, height = 400)
        ##textOutput("txt")
      ) #End of Main Panel
    ) #End of sidebar layout
  ) #End of fluidPage
) #End of ShinyUI
