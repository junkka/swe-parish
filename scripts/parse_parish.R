# parse parish info

library(rvest)
library(stringr)
library(plyr)
library(tidyr)
library(dplyr)

manual <- list()
pages <- list.files("scripts/.cache")

x <- ldply(pages, function(url) {


  file_name <- file.path("data-raw/.cache", url)
  url %>% str_split('/') %>% .[[1]] %>% last() %>% str_extract('[a-z]') %>% message()
  html_file <- readChar(file_name, file.info(file_name)$size)
  page <- html(html_file, encoding = "UTF-8")
  # page <- html(paste0('http://skatteverket.se', url)) 
  parishes <- page %>% html_node(".pagecontent") %>%  html_nodes("p")
  f <- function(va, ind) {
    # for each index find all in vars between ind and next ind
    ind <- c(ind, length(va) + 1)
    x <- c()
    for (i in 1:(length(ind) - 1)) {
      if ((ind[i] + 1) > (ind[i + 1] - 1)) 
        x <- c(x, NA)
      else
        x <- c(x, paste(va[(ind[i] + 1):(ind[i + 1] - 1)], collapse = " ") )
    }
    x 
  }
  previd <- NA
  a <- ldply(parishes[-1], function(x) {

    links <- x %>% html_nodes('a') 
    charid  <- previd
    previd <<- links %>% html_attr('name') %>% last()
    vars <- x %>% html_nodes('span strong') %>% html_text() %>% str_trim()
    all  <- x %>% html_nodes('span') %>% html_text() %>% str_trim()

    ind <- match(vars, all)
    
    values <- f(all, ind)

    # extract <a> as link
    ref <- links %>% html_attr('href') %>% 
      str_extract("\\#[A-Za-z0-9]{1,10}$") %>% 
      str_replace("#", "") %>% 
      na.omit() %>% 
      as.vector()
    
    if (length(ref) == 0){
      refn <- NULL 
    } else {
      refn <- paste0('link', c(1:length(ref)))
    }
    
    forkod <- str_extract(vars[1], "\\d{5,6}") %>% as.integer()
    name <- str_extract(vars[1], "^[ [:alpha:]-]*")
    vars   <- c('forkod', 'charid', 'name',  vars[-1], refn) %>% 
      str_replace_all(':', '') %>% 
      str_replace_all('\\.', '') %>% 
      str_trim() %>% 
      tolower()
    values <- c(forkod, charid, name, values[-1], ref)
    
    e <- data.frame(
      vars    = vars,
      values  = values,
      stringsAsFactors=F
    ) %>% 
    group_by(vars) %>% 
      summarise(
        values = paste(values, collapse = " ")
      ) %>% 
      as.data.frame()
    y <- e %>% mutate(
      name    = rep(name, nrow(e)),
      id      = rep(forkod, nrow(e)),
      length  = rep(mean(runif(10, 5.0, 7.5)), nrow(e))
    )

    # Evaluate
    ref <- c("arkiv", "charid", "födelsebok", "husförhörslängd", "forkod",
      "indelning", "link1","link2","link3","link4","län", "namn", "name", 
      "pastorat", "pastoratskod","övrigt")
    if (all(vars %in% ref) == FALSE) {
      # add to manual
      manual <<- c(manual, x)
      return(NULL)
    } else {
      return(y)
    }
    y

  })
})


file_name <- 'data-raw/h.html'
html_file <- readChar(file_name, file.info(file_name)$size)
a <- html(html_file, encoding = "UTF-8")
parishes <- a %>% html_nodes('p')
previd <- NA
x2 <- ldply(parishes, function(x) {

  library(rvest)
  library(stringr)
  # library(plyr)
  library(tidyr)
  library(dplyr)
  links <- x %>% html_nodes('a') 
  charid  <- previd
  previd <<- x %>% html_attr("id") %>% first()
  ref <- links %>% html_attr('href') %>% 
      str_extract("\\#[a-z0-9]{1,10}$") %>% 
      str_replace("#", "") %>% 
      na.omit() %>% 
      as.vector()
    
    if (length(ref) == 0){
      refn <- NULL 
    } else {
      refn <- paste0('link', c(1:length(ref)))
    }
    
  keys <- x %>% html_nodes('strong') %>% html_text() %>% str_replace_all(':', "") %>% str_trim() %>% tolower()
  name <- str_extract(keys[1], "^[ [:alpha:]-]*")
  forkod <- str_extract(keys[1], "\\d{5,6}") %>% as.integer()
  vars   <- c('forkod', 'charid', 'name',  keys[-1], refn) %>% 
    str_replace_all(':', '') %>% 
    str_replace_all('\\.', '') %>% 
    str_trim() %>% 
    tolower()
  values <- x %>% html_nodes('.value') %>% html_text() %>% str_trim()
  values <- c(values, rep(NA, (length(keys)-length(values))))
  values <- c(forkod, charid, name, values[-1], ref)

  e <- data.frame(
    vars    = vars,
    values  = values
  ) %>% 
  group_by(vars) %>% 
    summarise(
      values = paste(values, collapse = " ")
    ) %>% 
    as.data.frame()
  y <- e %>% mutate(
    name    = rep(name, nrow(e)),
    id      = rep(forkod, nrow(e)),
    length  = rep(mean(runif(10, 5.0, 7.5)), nrow(e))
  )
})

x3 <- rbind(x, x2)

b <- x3 %>% 
  mutate(
    pid = as.integer(factor(paste(name, id, length))),
    vars = as.character(vars),
    values = as.character(values)
  ) %>% 
  select(-name, -length, -id)

for_hist <- spread(b, vars, values) %>% 
  mutate(
    forkod = as.integer(forkod),
    pastoratskod = as.integer(pastoratskod)
  )

na_recode <- function(x) {
  x <- ifelse(x %in% c("", "NA"), NA, x)
  x
}

for_hist <- read.csv("data-raw/manual_parish.csv") %>% rbind(for_hist, .) %>% 
  mutate(
    county          = factor(floor(forkod/10000)),
    arkiv           = na_recode(arkiv),
    charid          = na_recode(charid),
    födelsebok      = na_recode(födelsebok),
    husförhörslängd = na_recode(husförhörslängd),
    indelning       = na_recode(indelning),
    län             = na_recode(län),
    link1           = na_recode(link1),
    link2           = na_recode(link2),
    link3           = na_recode(link3),
    name            = na_recode(name),
    namn            = na_recode(namn),
    övrigt          = na_recode(övrigt),
    pastorat        = na_recode(pastorat)
  )

colnames(for_hist) <- c(
  "pid",
  "arkiv",
  "charid",
  "fodelsebok",
  "forkod",
  "husforhorslangd",
  "indelning",
  "lan",
  "link1",
  "link2",
  "link3",
  "name",
  "namn",
  "ovrigt",
  "pastorat",
  "pastoratskod",
  "county"
  )

save(for_hist, file = "data/for_hist.rda")

