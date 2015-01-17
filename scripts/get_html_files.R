# get_html_files.R
library(rvest)
library(stringr)
library(plyr)
library(httr)
library(dplyr)

dir.create('scripts/.cache')

base_url <- "http://www.skatteverket.se/privat/folkbokforing/omfolkbokforing/folkbokforingigaridag/sverigesforsamlingargenomtiderna/forteckning/"
links <- html(base_url) %>% 
  html_node('#svid12_18e1b10334ebe8bc8000117531') %>% 
  html_nodes('a') %>% 
  html_attr('href')

x <- l_ply(links[c(1:7, 9:27)], function(url) {
  html <- GET(paste0('http://skatteverket.se', url))
  content2 = content(html,as="text")
  file_name <- str_split(url, "/") %>% unlist() %>% last()
  write(content2, file = sprintf("scripts/.cache/%s", file_name))
})
