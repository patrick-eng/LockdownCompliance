#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(shinythemes)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    theme = shinytheme("lumen"),

    # Application title and preamble
    titlePanel("Lockdown Compliance Across the United Kingdom"),
    tags$hr(),
    
    tags$br(),
    
    tags$b("Use the options below to select areas within the United Kingdom and see the 
            reported change in Google mobility trends in visits to places
            of different categories, relative to a pre-COVID-19 baseline 
            (median value for corresponding day of the week from Jan 3rd to 
            Feb 6th, 2020). Geographies available include cities and county areas.
            You can overlay national-level (UK) figures onto any other area using the checkbox."),
    tags$br(),
    tags$br(),
    tags$br(),

    # Sidebar for selections
    sidebarLayout(
        sidebarPanel(
            selectInput("area", "Select area:",
                        unique(as.factor(google$sub_region_1))
            ),
            
            selectInput("measurement", "Select type of place:",
                        selected = "Retail and Recreational",
                        c("Compliance Index",
                          "Retail and Recreational",
                          "Grocery and Pharmacy",
                          "Parks",
                          "Transit Stations",
                          "Workplaces",
                          "Residential")
            ),
            
            checkboxInput("national", 
                          "Include national figures?",
                          value=FALSE),
            
            tags$br(),
            tags$hr(),
            
            tags$p("Compliance Index is a simple mean
                   of all non-missing values in individual
                   indicators.")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("CompliancePlot")
        )
    ),
    
    tags$br(),
    tags$hr(),
    tags$footer("Data come from Google's Community Mobility reports: https://www.google.com/covid19/mobility/index.html?hl=en"),
    tags$br(),
    tags$footer("GitHub link for application code: https://github.com/patrick-eng/LockdownTrends"),
    
))
