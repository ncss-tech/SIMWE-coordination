## Setup project file system and other misc. actions
##
##


## don't source this document, it will clobber the existing data
stop()


## setup file system for sites
makeFS <- function(site.path = 'sites', sites) {
  
  v <- c('grid', 'vect', 'soil-data')
  
  for(i in sites) {
    sapply(v, function(.var) {
      dir.create(file.path(site.path, i, .var), recursive = TRUE)  
    })
  }
  
}

## start clean
unlink('sites', recursive = TRUE)

## starting suite of sites
s <- c('SJER', 'SFREC', 'coweeta', 'clay-center', 'shawnee-hills')
p <- 'sites'
makeFS(site.path = p, sites = s)


## add new sites here e.g.
# makeFS(site.path = p, sites = 'XXX')

