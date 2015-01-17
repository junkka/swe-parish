# clean_parse.R
pkgs <- c("rcustom", "stringr", "dplyr")
lapply(pkgs, library, character.only=T)

load('data/for_hist.rda')

# Complete missing
for_hist$name[1] <- "Sallerup"

# select distinct 
sfgt <- for_hist %>% group_by(pid) %>% filter(row_number() == 1) %>% as.data.frame()

# trim char
f <- function(x) {
  # Function content
  if (inherits(x, "character"))
    str_extract(x, "[-_\\.,;:\\(\\) [:alpha:]0-9]*") %>% str_trim()
  else 
    x
}
sfgt <- sfgt %>% mutate_each(funs(f))


charid <- sfgt %>% select(pid, charid, name) %>% rename(lid = pid, charlid = charid, lname = name) %>% group_by(charlid) %>% filter(row_number() == 1) %>% na.omit()
sfgt2 <- left_join(tbl_df(sfgt), charid, by =c("link1" = "charlid")) %>% mutate(link1 = lid, lname1 = lname) %>% select(-lid, -lname)
sfgt2 <- left_join(tbl_df(sfgt2), charid, by =c("link2" = "charlid")) %>% mutate(link2 = lid, lname2 = lname) %>% select(-lid, -lname)
sfgt2 <- left_join(tbl_df(sfgt2), charid, by =c("link3" = "charlid")) %>% mutate(link3 = lid, lname3 = lname) %>% select(-lid, -lname, -charid, pid:county, link1, link2, link3, lname1:lname3)

a <- plyr::dlply(sfgt2, "pid", function(x){
  if (all(is.na(c(x$link1, x$link2, x$link3))))
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
  ret
})
sfgt3 <- sfgt
sfgt3$links <- a
sfgt <- sfgt3 %>% select(-link1:-link3)
save(sfgt, file = "data/sfgt.rda")