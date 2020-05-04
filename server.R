#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    google <- read.csv("Global_Mobility_Report.csv", stringsAsFactors = FALSE) %>% 
        filter(country_region_code == "GB") %>% 
        mutate(date = as.Date(date, format = "%Y-%m-%d"),
               
               `Compliance Index` = rowMeans(
                   .[,c(6:10)], na.rm = TRUE),
               
               sub_region_1 = case_when(
                   sub_region_1 == "" ~ "United Kingdom",
                   TRUE ~ sub_region_1
               )
               
               ) %>% 
        rename(
            `Retail and Recreational` = retail_and_recreation_percent_change_from_baseline,
            `Grocery and Pharmacy` = grocery_and_pharmacy_percent_change_from_baseline,
            Parks = parks_percent_change_from_baseline,
            `Transit Stations` = transit_stations_percent_change_from_baseline,
            Workplaces = workplaces_percent_change_from_baseline,
            Residential = residential_percent_change_from_baseline
        ) %>% 
        droplevels() 
    
    output$CompliancePlot <- renderPlot({
        
        shiny::validate(
            need(
                !all(
                    is.na(google[google$sub_region_1==input$area,input$measurement])), 
                    "Sorry, there are no data for this particular selection."
                 ) 
        )
        
        area <- as.character(input$area)
        
        data <- subset(google, sub_region_1 == area)
        
        if(input$national==FALSE){
    
            plot(data$date, data[,input$measurement], type="l",
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020.",
                 xlab = "Date",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
                
        } else {
            
            national <- subset(google, sub_region_1 == "United Kingdom")
            
            plot(data$date, data[,input$measurement], type="l",
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020.",
                 xlab = "Date",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
            par(new=TRUE)
            plot(national$date, national[,input$measurement], type = "l", col="light blue",
                 xlab = "",
                 ylab = "",
                 axes = F)
            
        }

    })

})