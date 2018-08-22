#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#

library(Rcpp)
library(shiny)
library(ggplot2)
#library(plotly)
library(dplyr)

# Define server logic required to estimate/predict the avg weight of a chicken after a period of days
# and using by feeding the a specific type of diet. 
shinyServer(
  function(input, output, session) {
    CWdata<-ChickWeight
    
    ##Split Linear regression at Time=5.
    CWdata$Timesp<-ifelse(CWdata$Time-5>0, CWdata$Time-5,0)
    
    ##Create model where weight is a function of the interaction between Time and Diet
    mdl1<-lm(weight~Timesp+Time*Diet, data=CWdata)
    CWdata<-cbind(CWdata, predict(mdl1, interval = 'confidence'))
    
    ##Reset input values if Reset button is clicked
    observeEvent(input$reset, 
                 {updateSliderInput(session, inputId = "Tdays",
                                    label = "Number of days",
                                    min = 1, max = 21, value = 15)
                  updateSelectInput(session, inputId = "Diet", 
                                    label = "Chicken Food Diet:", 
                                    choices = c(1,2,3,4), 
                                    selected = 1)})
    
    ##Check or unCheck all values if Buttons are clicked
    observeEvent(input$selectall,
                 {updateCheckboxGroupInput(session, inputId = "DietLine", label="Plot Diet:", 
                                           choices=c(1,2,3,4), 
                                           selected=c(1,2,3,4),
                                           inline = T)})
    observeEvent(input$clearall,
                 {updateCheckboxGroupInput(session, inputId = "DietLine", label="Plot Diet:", 
                                           choices=c(1,2,3,4), 
                                           selected=c(),
                                           inline = T)})
    output$CWPlot1 <- renderPlot({
      
      newTime<-input$Tdays
      ##newTime<-15
      newDiet<-input$Diet
      ##newDiet<-2
      CWpred<-data.frame(Time=newTime, Diet=as.factor(newDiet))
      CWpred$Timesp<-ifelse(CWpred$Time-5>0, CWpred$Time-5,0)
      pred1<-predict(mdl1, newdata=CWpred)
      CWpred<-cbind(CWpred, weight=pred1)
      CWdata2<-filter(CWdata, Diet %in% input$DietLine)
      ##output$txt<-renderText(input$DietLine)
      ##Create plot
      plotA<-ggplot(CWdata, aes(x=Time, y=weight, color=Diet))+ 
        theme_bw()+
        xlim(-1,22)+
        ylim(0,400)+
        theme(plot.title = element_text(face="plain", hjust = 0.5))+
        theme(legend.position = "bottom")+
        scale_color_brewer(palette = "Set1")+
        geom_point(alpha=0)+
        geom_jitter(data=CWdata2, width=0.2, alpha=0.3, size=2)+
        ##Regression Lines
        geom_line(data=CWdata2, aes(Time, fit))+
        ##Regression Lines errors
        geom_ribbon(data=CWdata2, aes(ymin=lwr, ymax=upr), fill="gray", linetype=0, alpha=0.3, show.legend = FALSE)+
        ##Predicted Value
        geom_point(data=CWpred, aes(x=Time, y=weight), inherit.aes = FALSE,
                   shape=23, size=4, fill="blue", color="red", show.legend = FALSE)+
        geom_label(data=CWpred, aes(x=Time, y=weight, label=round(weight, digits = 1)), 
                   nudge_y = 22, show.legend = F, size=5)+
        ##annotate(geom="text", x=CWpred$Time, y=CWpred$weight+10, 
        ##        label=round(CWpred$weight, digits=2))+
        labs(x="Time (days)", y="Weight (gr)", title="Diet effect in Chicken Weight",
             color="Diet type")
      ##plotA<-ggplotly(plotA)
      #plotA<-style(plotA, hoverinfo='none')
      plotA
    })##End renderPlotly
  
  }##End Server function
)##End ShinyServer
