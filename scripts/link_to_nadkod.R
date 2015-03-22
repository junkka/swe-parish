# link to nadkod 
load("data/for_hist.rda")

library(histmaps)
library(stringr)
library(dplyr)

data(hist_parish)
parish_meta <- slot(hist_parish, "data") %>% 
  mutate(lanskod = floor(nadkod/10000000))

# add pid to all parish_meta s 

linked1 <- left_join(tbl_df(for_hist), parish_meta, by = "forkod") %>% 
  filter(!is.na(nadkod)) %>% 
  select(pid, nadkod)

miss_par <- anti_join(tbl_df(parish_meta), for_hist, by = "forkod")

# get for_hist wihtout forkod links with unique name
miss_for <- anti_join(tbl_df(for_hist), parish_meta, by = "forkod") %>% 
  select(name, pid, county) %>% 
  mutate(name = tolower(word(name))) %>% 
  group_by(name, county) %>% 
  filter(n() == 1) %>% 
  ungroup() %>% 
  mutate(lanskod = as.integer(as.character(county)))

p_codes <- tbl_df(parish_meta) %>% select(forkod, nadkod, socken, lanskod) %>% 
  mutate(name = tolower(word(socken))) %>% 
  group_by(name, lanskod) %>% 
  filter(n() == 1) %>% 
  ungroup()

# link by name
linked2 <- left_join(miss_for, p_codes, by = c("name", "lanskod")) %>% 
  filter(!is.na(nadkod)) %>% 
  select(nadkod, pid) %>% 
  rbind(linked1)


miss_for2 <- anti_join(tbl_df(for_hist), linked2, by = "pid") %>% 
  select(pid, forkod, name)

# link by for_hist link1 forkod and name
# where link2 is.na and link1 !is.na add forkod and name from self
missing_full <- miss_for2 %>% select(pid) %>% 
  left_join(tbl_df(for_hist), ., by = "pid") %>% 
  filter(
    is.na(link2), 
    !is.na(link1),
    is.na(fodelsebok),
    is.na(lan),
    is.na(namn),
    is.na(husforhorslangd),
    is.na(indelning),
    is.na(pastorat),
    is.na(pastoratskod)
  ) %>% 
  select(pid, link1)

# link to for_hist by charid = link1
miss_w_link <- tbl_df(for_hist) %>% 
  select(charid, forkod, name) %>% 
  left_join(missing_full, ., by = c("link1" = "charid")) 

linked3 <- left_join(miss_w_link, parish_meta, by = "forkod") %>% 
  filter(!is.na(nadkod)) %>% 
  select(nadkod, pid) %>% 
  rbind(linked2) %>% 
  distinct()

manual <- anti_join(tbl_df(for_hist), linked3, by = "pid") %>% 
  select(pid, forkod, name)


# write.csv(manual, file = "scripts/manual_nakod.csv", row.names = FALSE)
miss_par <- anti_join(tbl_df(parish_meta), linked3, by = "nadkod") %>% 
  select(nadkod, socken,from, tom)
# write.csv(miss_par, file = "scripts/manual_pid.csv", row.names = FALSE)
nad_to_pid <- read.csv("scripts/manual_pid.csv") %>% select(nadkod, pid) %>% 
  rbind(linked3)
save(nad_to_pid, file = "data/nad_to_pid.rda")

# p_codes <- tbl_df(parish_meta) %>% 
#   select(forkod, nadkod, socken, lanskod, from, tom)
