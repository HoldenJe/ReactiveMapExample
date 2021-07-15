# Load relevant libraries
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

plot_ly(plot_dat,x= ~X, y= ~Y, color =~Lake, type = 'scatter', mode = "markers")

(selected <- selectFeatures(mydata, map = mymap, mode = "click"))

plot_ly(dplyr::filter(plot_dat, Lake %in% selected$Lake),x= ~X, y= ~Y, color =~Lake, 
        type = 'scatter', mode = "markers")
