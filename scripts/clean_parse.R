# clean_parse.R
pkgs <- c("rcustom", "stringr", "histmaps", "dplyr")
lapply(pkgs, library, character.only=T)

load('data/for_hist.rda')
sfgt <- for_hist

charid <- sfgt %>% 
  select(pid, charid, name) %>% 
  rename(lid = pid, charlid = charid, lname = name) %>% 
  group_by(charlid) %>% 
  filter(row_number() == 1) %>% na.omit()
sfgt2 <- left_join(tbl_df(sfgt), charid, by =c("link1" = "charlid")) %>% mutate(link1 = lid, lname1 = lname) %>% select(-lid, -lname)
sfgt2 <- left_join(tbl_df(sfgt2), charid, by =c("link2" = "charlid")) %>% mutate(link2 = lid, lname2 = lname) %>% select(-lid, -lname)
sfgt2 <- left_join(tbl_df(sfgt2), charid, by =c("link3" = "charlid")) %>% mutate(link3 = lid, lname3 = lname) %>% select(-lid, -lname)
sfgt2 <- left_join(tbl_df(sfgt2), charid, by =c("link4" = "charlid")) %>% mutate(link4 = lid, lname4 = lname) %>% select(-lid, -lname, -charid, pid:county, link1, link2, link3, link4, lname1:lname4)

a <- plyr::dlply(sfgt2, "pid", function(x){
  if (all(is.na(c(x$link1, x$link2, x$link3, x$link4))))
    return(NA)
  ret <- list()
  if (!is.na(x$link1)) {
    ret[[length(ret) +1]] <- data.frame(id = x$link1, name = x$lname1, stringsAsFactors = F)  
  }
  if (!is.na(x$link2)) {
    ret[[length(ret) +1]] <- data.frame(id = x$link2, name = x$lname2, stringsAsFactors = F)
  }
  if (!is.na(x$link3)) {
    ret[[length(ret) +1]] <- data.frame(id = x$link3, name = x$lname3, stringsAsFactors = F)
  }
  if (!is.na(x$link4)) {
    ret[[length(ret) +1]] <- data.frame(id = x$link4, name = x$lname4, stringsAsFactors = F)
  }
  ret
})
sfgt3 <- sfgt
sfgt3$links <- a
# for each pid get nadkod as data.frame
data(nad_to_pid)
data(hist_parish)
parish_meta <- slot(hist_parish, "data") %>% 
  mutate(socken = Hmisc::capitalize(tolower(socken)))

b <- plyr::llply(unique(sfgt3$pid), function(x){
  dat <- nad_to_pid %>% filter(pid == x) %>% 
    left_join(parish_meta, by = "nadkod") %>% 
    select(nadkod, socken, from, tom) %>% 
    arrange(from)
  if (nrow(dat) < 1) {
    return(NA)
  }
  ntp <- nad_to_pid %>% group_by(nadkod) %>% 
    filter(row_number() == 1)
  # get relations
  bb <- plyr::llply(dat$nadkod, function(y){
    # add relaion pid to 
    rel <- parish_relations %>% 
      filter(nadkod == y) %>% 
      select(nadkod = nadkod2, relation) %>% 
      left_join(parish_meta, by = "nadkod") %>% 
      left_join(ntp, by = "nadkod") %>% 
      select(nadkod, socken, relation, from, tom, pid) %>% 
      arrange(tom)
  })
  dat$rel <- bb
  return(dat)

})
sfgt3$nads <- b
sfgt <- sfgt3 %>% select(-link1:-link4)
save(sfgt, file = "data/sfgt.rda")