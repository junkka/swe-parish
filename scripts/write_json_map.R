# write_json_map.R

# For each county get map and write geojson

library(historicalmaps)
library(dplyr)
library(rgdal)

dir.create('output/data', showWarnings = FALSE)
# get all counties
lanskod <- nad_sp@data %>% select(lanskod) %>% distinct() %>% .$lanskod

plyr::l_ply(lanskod, function(a){
  dat <- nad_sp[nad_sp@data$lanskod == a & nad_sp@data$tom == 9999, ]
  writeOGR(dat, sprintf("output/data/map%s.geo.json", a), "svelan", driver = "GeoJSON")
})

# svelan2 <- as(svelan, "SpatialLines")
# svelan2 <- SpatialLinesDataFrame(svelan2, svelan@data)
# writeOGR(svelan2, "output/data/svelan.geo.json", "svelan", driver = "GeoJSON")
