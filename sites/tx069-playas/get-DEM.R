library(elevatr)
library(sf)
library(raster)
library(terra)

# https://casoilresource.lawr.ucdavis.edu/soil-properties/?prop=texture_025&lat=34.3774&lon=-101.7197&z=9
# https://casoilresource.lawr.ucdavis.edu/gmap/?loc=34.47387,-102.12719,z13
# TX069
bb <- '-102.1681 34.4483,-102.1681 34.5201,-102.0177 34.5201,-102.0177 34.4483,-102.1681 34.4483'
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


# reasonable local CRS: UTM z13 32613
# consider warping in GRASS with r.proj
# 
e.utm <- terra::project(e, 'epsg:32613', method = 'cubicspline', res = 8)


# save
terra::writeRaster(e.utm, filename = 'grid/elev.tif', overwrite = TRUE, gdal = list('COMPRESS=LZW'))
