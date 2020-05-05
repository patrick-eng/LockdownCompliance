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

# Define server logic 
shinyServer(function(input, output, session) {
    
    
    
    # Read in and adapt data #
    
    # Google mobility trends
    google <- read.csv("Global_Mobility_Report.csv", stringsAsFactors = FALSE) %>% 
        filter(country_region_code == "GB") %>% 
        mutate(date = as.Date(date, format = "%Y-%m-%d"),
               
               # Make compliance index
               `Compliance Index` = rowMeans(
                   .[,c(6:10)], na.rm = TRUE),
               
               # Add UK into list of areas available 
               sub_region_1 = case_when(
                   sub_region_1 == "" ~ "United Kingdom",
                   TRUE ~ sub_region_1
               )
               
        ) %>% 
        rename(
            # Renaming for inputs
            `Retail and Recreational` = retail_and_recreation_percent_change_from_baseline,
            `Grocery and Pharmacy` = grocery_and_pharmacy_percent_change_from_baseline,
            Parks = parks_percent_change_from_baseline,
            `Transit Stations` = transit_stations_percent_change_from_baseline,
            Workplaces = workplaces_percent_change_from_baseline,
            Residential = residential_percent_change_from_baseline
        ) %>% 
        droplevels()
    
    
    # ONS cases
    ons_cases <- read.csv("coronavirus-cases_latest.csv", stringsAsFactors = FALSE) %>%
        mutate(date = as.Date(Specimen.date, format = "%Y-%m-%d"),
               Area.name = case_when(
                   Area.name == "England" ~ "United Kingdom",
                   TRUE ~ Area.name
               )
               ) %>% 
        rename(`Daily New Confirmed Cases` = Daily.lab.confirmed.cases,
               `Cumulative Confirmed Cases` = Cumulative.lab.confirmed.cases)
    
    
    # ONS deaths
    ons_deaths <- read.csv("coronavirus-deaths_latest.csv") %>% 
        mutate(date = as.Date(Reporting.date, format = "%Y-%m-%d")) %>% 
        rename(`Daily New Deaths` = Daily.change.in.deaths,
               `Cumulative Deaths` = Cumulative.deaths)
    
    ons_data <- merge(ons_cases, ons_deaths, by=c("date", "Area.name"), all=TRUE)
    
    # Rainfall 
    rain <- read.delim("HadEWP_daily_qc.txt", skip=3, header=FALSE, sep="", na.strings=-99.99) %>% 
        mutate(YearMonth = paste(V1, V2)) %>% 
        filter(YearMonth == "2020 3" | YearMonth == "2020 4")
    
    rain <- c(as.numeric(rain[1,-c(1:2, 34)]), as.numeric(rain[2,-c(1:2, 34)]))
    
    rainfall <- seq.Date(from=as.Date("2020-03-01"), to = Sys.Date(), by=1) %>% 
        .[1:length(rain)] %>% 
        as.data.frame()
    
    rainfall$rain <- rain
    
    
    
    
    # update selectize with choices for areas
    updateSelectizeInput(session, "area",
                         choices = unique(as.factor(google$sub_region_1)),
                         server = TRUE)
                         
    # update selectize with choices for areas
    updateSelectizeInput(session, "area_c",
                         choices = unique(as.factor(ons_data$Area.name)),
                         server = TRUE)
    
    
    
    # Draw the lockdown plot
    output$CompliancePlot <- renderPlot({
        
        # Check to make sure there is at least some info to plot in user selection
        shiny::validate(
            need(
                !all(
                    is.na(google[google$sub_region_1==input$area,input$measurement])), 
                    "Sorry, there are no data for this particular selection."
                 ) 
        )
        
        # Probably needless, but safety catch for subset
        area <- as.character(input$area)
        
        # Make data subset
        data <- subset(google, sub_region_1 == area)
        
        
        if(input$national==FALSE & input$rainfall==FALSE){
    
            # Graph - no national overlay
            plot(data$date, data[,input$measurement], type="l",
                 ylim = c(-90,50),
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020.",
                 xlab = "",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
                
        } 
        
        if(input$national==TRUE & input$rainfall==FALSE){
            
            # Graph - national overlay selected, so get data
            national <- subset(google, sub_region_1 == "United Kingdom")
            
            # Graph - plot national
            plot(data$date, data[,input$measurement], type="l",
                 ylim = c(-90,50),
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020.",
                 xlab = "",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
            par(new=TRUE)
            plot(national$date, national[,input$measurement], type = "l", col="light blue",
                 ylim = c(-90,50),
                 xlab = "",
                 ylab = "",
                 axes = F)
            
        }
        
        if(input$national==FALSE & input$rainfall==TRUE) {
            
            # Graph - plot rainfall
            plot(data$date, data[,input$measurement], type="l",
                 ylim = c(-90,50),
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020. \n Precipitation figures are in millimetres.",
                 xlab = "",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
            par(new=TRUE)
            plot(rainfall$., rainfall$rain, type = "h", col="blue",
                 xlab = "",
                 ylab = "",
                 xaxt = "n",
                 yaxt = "n")
            axis(side=4)
        }
        
        if(input$national==TRUE & input$rainfall==TRUE) {
            
            # Graph - national overlay selected, so get data
            national <- subset(google, sub_region_1 == "United Kingdom")
            
            # Graph - plot national and rainfall
            plot(data$date, data[,input$measurement], type="l",
                 ylim = c(-90,50),
                 main = paste(input$measurement, ": ", input$area, sep=""),
                 sub = "Grey line: No change. Red line: Lockdown announced, 23rd March 2020. \n Precipitation figures are in millimetres.",
                 xlab = "",
                 ylab = "% Change in Activity") ; abline(0,0, col="grey") ; abline(v=as.Date("2020-03-23"), col="red")
            par(new=TRUE)
            plot(national$date, national[,input$measurement], type = "l", col="light blue",
                 ylim = c(-90,50),
                 xlab = "",
                 ylab = "",
                 axes = F)
            par(new=TRUE)
            plot(rainfall$., rainfall$rain, type = "h", col="blue",
                 xlab = "",
                 ylab = "",
                 xaxt = "n",
                 yaxt = "n")
            axis(side=4)
        }

    })
    
    output$CasesPlot <- renderPlot({
        
        # Check to make sure there is at least some info to plot in user selection
        shiny::validate(
            need(
                !all(
                    is.na(ons_data[ons_data$Area.name==input$area_c,input$covid_i])), 
                "Sorry, there are no data for this particular selection."
            ) 
        )
             
            if(input$covidfig==TRUE){   
                
                data_c <- subset(ons_data, Area.name == input$area_c)
            
                # Graph - plot cases/deaths
                plot(data_c$date, data_c[,input$covid_i], type="l",
                     main = paste(input$covid_i, ": ", input$area_c, sep=""),
                     xlab = "Date",
                     ylab = input$covid_i) ; abline(v=as.Date("2020-03-23"), col="red")
            
   
        }
    })

})
