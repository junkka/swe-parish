
write_f <- function(a, filepath){
  write(a, file = filepath, append = TRUE)
  
}

render_parish <- function(d){
  library(histmaps)
  library(dplyr)
  pars <- hist_county@data  %>% select(name, lan)  %>% distinct() %>% rename(county_name = name)
  
  d <- d %>%
    mutate(county = as.integer(as.character(county))) %>% 
    left_join(pars, by = c("county" = "lan"))
  
  plyr::l_ply(1:nrow(d), function(a){
    tempyaml <- to_yaml(d[a, ])
    render("parish.Rmd", output_file = paste0(d[a, ]$pid, ".html"), output_dir = "output/parish")  
  })
}

html_parish <- function(css = NULL, ...){
  rmarkdown::html_document(
    pandoc_args = file.path(tempdir(), "temp.yaml"),
    mathjax = NULL, css = css, ...)
}

to_yaml <- function(d, temp_dir = tempdir()){
  a <- as.list(d[ ,c(1:15, 18)])
  a <- a[lapply(a, function(x) is.na(x)) == FALSE]
  if (all(!is.na(d$links[[1]][[1]])))
    a$links <- as.list(d$links[[1]][[1]])
  nads <- d$nads[[1]]
  if (all(!is.na(nads))){
    a$nads <- plyr::llply(c(1:nrow(nads)), function(x){
      res <- as.list(nads[x,1:4])
      rels <- nads[x,5][[1]]
      if (nrow(rels) > 0)
        res$rel <- unname(split(rels, 1:nrow(rels)))
      res
    })  
  }
  
  b <- list(parish = a)
  temp_file <- "temp.yaml"
  filepath <- file.path(temp_dir, temp_file)
  unlink(filepath)
  
  cat("---\n", file = filepath)
  write_f(as.yaml(b), filepath)
  write_f("---", filepath)
  return(filepath)
}