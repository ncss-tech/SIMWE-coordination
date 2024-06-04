library(terra)

f <- list.files(path = 'sites', pattern = 'elev.tif$', recursive = TRUE, full.names = TRUE)


sink(file = 'site-CRS-info.txt')

.tash <- lapply(f, function(i) {
  
  .site <- strsplit(i, '/', fixed = TRUE)[[1]][2]
  .crs <- crs(rast(i))
  
  cat(sprintf("%s:\n---------------------------\n", .site))
  cat(sprintf("%s\n------------------------------------------------------------------------------------------------------------\n\n", .crs))
  
})

sink()

