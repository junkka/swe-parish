# write_json_map.R

# For each county get map and write geojson

library(histmaps)
library(dplyr)
library(rgdal)

dir.create('output/data', showWarnings = FALSE)
# get all counties

lanskod <- hist_boundaries(1990, "county", "meta") %>% .$lan

map_d <- hist_boundaries(1990, "par")

plyr::l_ply(lanskod, function(a){
  dat <- subset(map_d, county == a)
  writeOGR(dat, sprintf("output/data/map%s.geo.json", a), "svelan", driver = "GeoJSON")
})

# svelan2 <- as(svelan, "SpatialLines")
# svelan2 <- SpatialLinesDataFrame(svelan2, svelan@data)
# writeOGR(svelan2, "output/data/svelan.geo.json", "svelan", driver = "GeoJSON")
