# Goal of this app is to start with the interactive mapview plot
# Be able to select a point on the map and save the selection using selectFeatures
# pass this SAM # to plotly to plot the temperature profile
# something like: https://r-spatial.org/r/2017/06/09/mapedit_0-2-0.html#shiny-modules
# but in an interface in selectFeatures(..., mode = "click")

library(shiny)
library(leaflet)
library(mapview)
library(mapedit) 
library(sf)
library(plotly)
library(dplyr)

# Create some geospatial data
Lake <- c("Superior", "Huron", "Michigan", "Erie", "Ontario")
Latitude <- c(47.572376, 44.743377, 43.947419, 42.206353, 43.650825)
Longitude <- c(-87.133282, -82.461347, -87.078451, -80.963942, -77.886872)
mydata <- data.frame(Lake, Latitude, Longitude)
mydata <- st_as_sf(mydata, coords = c("Longitude", "Latitude"),
                   crs = "+proj=longlat +datum=WGS84")

(mymap <- leaflet(mydata) %>% addTiles() %>% addCircleMarkers())

# Create data for plots
plot_dat <- data.frame(Lake = rep(Lake, 5), 
                       X = rep(1:5, each = 5),
                       Y = c(1:5, 2*(1:5), 3*(1:5), 4*(1:5), 5*(1:5)))

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Example App"),
    
    #  
    fluidPage(
        h4("Currently in select mode. Want in 'click' mode"),
        # create the map plot editor
        column (6,
                editModUI("editor")
        ), 
        
        # Generate the plotly plot
        column (6,
                h4("Plotly plot will appear here when selection complete."),
                plotlyOutput("fig2")
        )
        
        
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$mapPlot <- renderLeaflet({
        mapview(mydata, map=mymap)@map
    })
    
    edits <- callModule(editMod, "editor", mapview(mydata, mymap)@map)
    
    output$fig2 <- renderPlotly({
        req(edits()$finished)
        selected_dat <- st_intersection(edits()$finished, mydata)
        req(nrow(selected_dat) > 0)
        sub_plot_dat <- plot_dat %>% dplyr::filter(Lake %in% selected_dat$Lake)
        fig2 <- plot_ly(sub_plot_dat, 
                        x= ~X, y= ~Y, color =~Lake, 
                        type = 'scatter', mode = "markers")
    }
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
