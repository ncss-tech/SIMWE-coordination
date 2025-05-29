library(elevatr)
library(sf)
library(raster)
library(terra)

# https://casoilresource.lawr.ucdavis.edu/gmap/?loc=38.00982,-120.41187,z13
# Sonora, CA
bb <- '-120.5360 37.9434,-120.5360 38.0689,-120.3008 38.0689,-120.3008 37.9434,-120.5360 37.9434'
wkt <- sprintf("POLYGON((%s))", bb)
a <- vect(wkt, crs = 'epsg:4326')

# for now use 8m data (z = 13)
# later, use 4m data (z = 14)
# have to work through sf / raster objects
e <- get_elev_raster(st_as_sf(a), z = 13)

# convert to spatRaster
e <- rast(e)

# unload raster package
# conflicting namespace
detach("package:raster", unload = TRUE)


# reasonable local CRS: UTM z10 32610
# consider warping in GRASS with r.proj
# 
e.utm <- terra::project(e, 'epsg:32610', method = 'cubicspline', res = 8)


# save
terra::writeRaster(e.utm, filename = 'grid/elev.tif', overwrite = TRUE, gdal = list('COMPRESS=LZW'))
