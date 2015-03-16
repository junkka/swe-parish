render_page <- function(clean = FALSE) {
  library(rmarkdown)
  if (!file.exists('scripts/.cache')){
    dir.create('scripts/.cache')
    source('get_html_files')
  }
  if (!file.exists('data/sfgt.rda')){
    source('scripts/parse_parish.R')
    source('scripts/clean_parse.R')
  }
  if (clean) {
    unlink('output/*', recursive = TRUE)
    source("scripts/write_json_map.R")
  }
  dir.create('output/data', showWarnings = FALSE)
  dir.create('output/js', showWarnings = FALSE)
  dir.create('output/css', showWarnings = FALSE)
  file.copy('views', 'output', recursive = TRUE)
  file.copy('js', 'output', recursive = TRUE)
  file.copy('css', 'output', recursive = TRUE)
  
  if (clean) {
    library(jsonlite)
    load('data/sfgt.rda')

    plyr::d_ply(sfgt, "pid", function(a){
      writeLines(toJSON(a, pretty = F), sprintf('output/data/%d.json', a$pid))
    })

    json <- sfgt[ ,c(1,5, 7:12,14:16)]
    writeLines(toJSON(json, pretty = F), 'output/data/parishes.json')

  }
  render('index.Rmd', output_dir='output')
}