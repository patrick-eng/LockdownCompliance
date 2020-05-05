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
library(shinysky)


# Define UI for application
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
            You can overlay national-level (UK) figures onto any other area using the checkbox.
            You can also overlay UK-level precipitation figures onto the plot.
            Also available are COVID-19 cases (local authorities in England) and death rates
            (National and sub-national)."),
    tags$br(),
    tags$br(),
    tags$br(),

    # Sidebar for selections
    sidebarLayout(
        sidebarPanel(
            
            selectizeInput("area", "Search for or select area:",
                        choices = NULL, selected = NULL
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
            
            checkboxInput("rainfall", 
                          "Include precipitation figures?",
                          value=FALSE),
            
            tags$br(),

            tags$p(tags$em("Compliance Index is a simple mean
                   of all non-missing values in individual
                   indicators.")),
            
            tags$br(),
            tags$br(),
            tags$br(),
            tags$hr(),
            tags$br(),
            tags$br(),
            tags$br(),

            checkboxInput("covidfig", 
                          "Show COVID-19 Figures?",
                          value=FALSE),
            
            selectizeInput("area_c",
                           "Search for or select area",
                           choices = NULL,
                           selected = NULL),
            
            selectInput("covid_i", "Select COVID-19 statistic:",
                        selected = "Daily new cases",
                        c("Daily New Confirmed Cases",
                          "Cumulative Confirmed Cases",
                          "Daily New Deaths",
                          "Cumulative Deaths")
            ),

            tags$br(),
            
            tags$p(tags$em("ONS cases data are measured at Local Authority level or NUTS1 regions,
                            and as such do not map perfectly onto the Google Mobiltiy data.
                            Data on deaths are currently not available at authority level. 
                            Cases data are not yet available in Scotland or Wales.")),
            
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("CompliancePlot"),
            
            tags$br(),
            tags$br(),
            
            plotOutput("CasesPlot")
        ),
    ),
    
    tags$br(),
    tags$hr(),
    tags$footer(paste("Lockdown compliance data come from 'Google LLC COVID-19 Community Mobility Reports' at https://www.google.com/covid19/mobility/ Accessed: ", Sys.Date(), ".", sep="")),
    tags$br(),
    tags$footer(paste("Figures for confirmed cases and deaths come from the Office for National statistics, at https://coronavirus.data.gov.uk/ Accessed: ", Sys.Date(), ".", sep="")),
    tags$br(),
    tags$footer(paste("Precipitation data come from the Met Office Hadley Centre, at https://www.metoffice.gov.uk/hadobs/hadukp/ Accessed: ", Sys.Date(), ".", sep="")),
    tags$br(),
    tags$footer("GitHub link for application code: https://github.com/patrick-eng/LockdownTrends"),
    
))
