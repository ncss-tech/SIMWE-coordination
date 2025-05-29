# latest from GitHub
# remotes::install_github("ncss-tech/soilDB", dependencies = FALSE)
library(soilDB)

# wrangling polygons and CRS transformations
library(sf)

# raster data / analysis
# need latest: install.packages('terra', repos='https://rspatial.r-universe.dev')
library(terra)

# figures
library(lattice)
library(tactile)

# soil classification
library(aqp)

# color palettes and manipulation
library(RColorBrewer)
library(colorspace)



bb <- '-102.1681 34.4483,-102.1681 34.5201,-102.0177 34.5201,-102.0177 34.4483,-102.1681 34.4483'
wkt <- sprintf("POLYGON((%s))", bb)
a <- vect(wkt, crs = 'epsg:4326')

# fetch gSSURGO map unit keys at native resolution (30m)
mu <- mukey.wcs(aoi = a, db = 'gssurgo')

# extract RAT for thematic mapping
rat <- cats(mu)[[1]]

# variables of interest
vars <- c('sandtotal_r', 'silttotal_r', 'claytotal_r', 'dbthirdbar_r', 'wthirdbar_r', 'wfifteenbar_r', 'ksat_r')

# get thematic data from SDA
# dominant component
# depth-weighted average
p <-  get_SDA_property(property = vars,
                       method = "Dominant Component (Numeric)", 
                       mukeys = as.integer(rat$mukey),
                       top_depth = 0,
                       bottom_depth = 15)


.v <- c('sandtotal_r', 'silttotal_r', 'claytotal_r', 'dbthirdbar_r', 'wthirdbar_r', 'wfifteenbar_r')
R <- ROSETTA(p, vars = .v, v = '3')
R

xyplot(10^ksat ~ ksat_r, data = R)

# merge aggregate soil data into RAT
rat <- merge(rat, R, by.x = 'mukey', by.y = 'mukey', sort = FALSE, all.x = TRUE)

# requires that grid cell ID (mukey) be numeric
rat$mukey <- as.integer(rat$mukey)
levels(mu) <- rat

ksat <- catalyze(mu)[['ksat']]
plot(10^(ksat), axes = FALSE)

ksat_r <- catalyze(mu)[['ksat_r']]
plot(ksat_r, axes = FALSE)

# convert Ksat -> cm/day
x <- c(
  10^ksat,
  ksat_r * 8.64
)

names(x) <- c('Ksat via ROSETTA cm/day', 'Ksat from SSURGO cm/d')

plot(x, axes = FALSE)

plot(x$`Ksat via ROSETTA cm/day` - x$`Ksat from SSURGO cm/d`)


ssc <- catalyze(mu)[[c('sandtotal_r', 'silttotal_r', 'claytotal_r')]]

texture.class <- ssc[[1]]
names(texture.class) <- 'soil.texture'

values(texture.class) <- ssc_to_texcl(
  sand = values(ssc[['sandtotal_r']]), 
  clay = values(ssc[['claytotal_r']]), 
  droplevels = FALSE
)

plot(texture.class, axes = FALSE)








