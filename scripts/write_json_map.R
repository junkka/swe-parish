# write_json_map.R

# For each county get map and write geojson

library(histmaps)
library(dplyr)
library(rgdal)

dir.create('output/data', showWarnings = FALSE)
# get all counties

lanskod <- hist_boundaries(1990, "county", "meta") %>% .$lan

county <- hist_boundaries(1990, "county")

map_d <- hist_boundaries(1990, "par")



plyr::l_ply(lanskod, function(a){
  dat <- subset(map_d, county == a)
  back <- cut_spbox(county, dat, 10000)
  # back_line <- as(back, "SpatialLines")
  # back_line <- SpatialLinesDataFrame(back_line, back@data)
  writeOGR(dat, sprintf("output/data/map%s.geo.json", a), "svelan", driver = "GeoJSON")
  writeOGR(back, sprintf("output/data/back%s.geo.json", a), "background", driver = "GeoJSON")
})
