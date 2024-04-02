## Setup project file system and other misc. actions
##
##


## don't source this document, it will clobber the existing data
stop()


## setup file system for sites
makeFS <- function(site.path = 'sites', sites) {
  
  unlink(site.path, recursive = TRUE)
  
  v <- c('grid', 'vect', 'soil-data')
  
  for(i in sites) {
    sapply(v, function(.var) {
      dir.create(file.path(site.path, i, .var), recursive = TRUE)  
    })
  }
  
}

# starting suite of sites
s <- c('SJER', 'SFREC', 'coweeta', 'clay-center')
p <- 'sites'
makeFS(site.path = p, sites = sites)


# add new sites here 