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

# add pid
load("data/sfgt.rda")

pids <- sfgt %>% select(pid, forkod) %>% group_by(forkod) %>% 
  filter(row_number() == 1)

map_d@data <- left_join(map_d@data, pids)

plyr::l_ply(lanskod, function(a){
  dat <- subset(map_d, county == a)
  s_cou <- subset(county, lan != a)
  if (a == 9)
    s_cou <- county
  back <- cut_spbox(s_cou, dat, 15000)
  writeOGR(dat, sprintf("output/data/map%s.geo.json", a), "svelan", driver = "GeoJSON")
  writeOGR(back, sprintf("output/data/back%s.geo.json", a), "background", driver = "GeoJSON")
})
