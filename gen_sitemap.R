gen_sitemap <- function(x){
  head <- '<?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
  tail <- '</urlset>'
  today <- Sys.Date()
  
  base_item <- paste0("      <url>
        <loc>http://johanjunkka.com/swe-parish/</loc>
        <lastmod>", today ,"</lastmod>
        <changefreq>yearly</changefreq>
        <priority>1.0</priority>
      </url>")
  item <- c()
  for (i in x){
    item <- c(item, paste0('      <url>
        <loc>http://johanjunkka.com/swe-parish/parish/', i, '.html</loc>
        <lastmod>', today, '</lastmod>
        <changefreq>yearly</changefreq>
        <priority>0.5</priority>
      </url>'))
  }
  
  ret <- c(head, base_item, item, tail)
}
