library(soilDB)
library(terra)
library(aqp)

## TODO:
# * hydraulic properties via ROSETTA
# * surface properties related to runoff
# * aggregation / subset to specific depth-interval
# * possible re-sampling to common grid spacing
# 


#' @param s character, site name and path
getSoilData <- function(s) {
  
  # output base path
  .p <- file.path('sites', s)
  
  # use the elevation grid for this site to generate a BBOX
  # 10m USGS DEM
  e <- try(rast(file.path(.p, 'grid', 'elev.tif')))
  
  # trap most common error
  if(class(e) == 'try-error') {
    stop('elevation grid missing')
  }
  
  # map unit polygons
  # automatic transformation of BBOX to GCS WGS84 (4326)
  mu.poly <- SDA_spatialQuery(e, what = 'mupolygon', geomIntersection = TRUE)
  
  # 30m map unit key grid
  mu.grid <- mukey.wcs(e, db = 'gssurgo')
  
  # warp mukey grid to source PCS
  # inherits grid parameters from elevation grid
  # these are map unit keys = NN resampling
  mu.grid <- project(mu.grid, e, method = 'near')
  
  # init raster attribute table (RAT)
  mu.grid <- as.factor(mu.grid)
  varnames(mu.grid) <- 'mukey'
  
  # transform mu polygons to source PCS
  mu.poly <- project(mu.poly, e)
  
  # save static versions
  
  # mukey grid as 32bit unsigned integer to prevent collisions
  writeRaster(mu.grid, filename = file.path(.p, 'grid', 'ssurgo-mukey.tif'), overwrite = TRUE, datatype = 'INT4U')
  
  # mu polygons
  writeVector(mu.poly, filename = file.path(.p, 'vect', 'ssurgo.shp'), overwrite = TRUE)
  
  # tabular data
  # use unique combination of map unit keys from both sources
  .mukeys <- as.integer(unique(c(mu.poly$mukey, levels(mu.grid)[[1]]$mukey)))
  
  ssurgo.mu <- SDA_query(sprintf("SELECT * FROM mapunit WHERE mukey IN %s", format_SQL_in_statement(.mukeys)))
  ssurgo.co <- SDA_query(sprintf("SELECT * FROM component WHERE mukey IN %s", format_SQL_in_statement(.mukeys)))
  
  .cokeys <- unique(ssurgo.co$cokey)
  ssurgo.hz <- SDA_query(sprintf("SELECT * FROM chorizon WHERE cokey IN %s", format_SQL_in_statement(.cokeys)))
  
  # save pieces
  save(ssurgo.mu, ssurgo.co, ssurgo.hz, file = file.path(.p, 'soil-data', 'ssurgo-tab-data.rda'))
  
  # SoilProfileCollection representation
  # upgrade tabular data -> SPC
  depths(ssurgo.hz) <- cokey ~ hzdept_r + hzdepb_r
  site(ssurgo.hz) <- ssurgo.co
  site(ssurgo.hz) <- ssurgo.mu
  
  # set horizon name
  hzdesgnname(ssurgo.hz) <- 'hzname'
  
  # compute depth class
  sdc <- getSoilDepthClass(ssurgo.hz)
  site(ssurgo.hz) <- sdc
  
  # classify <2mm soil texture class
  ssurgo.hz$texture <- ssc_to_texcl(sand = ssurgo.hz$sandtotal_r, clay = ssurgo.hz$claytotal_r, simplify = TRUE) 
  
  # save
  saveRDS(ssurgo.hz, file = file.path(.p, 'soil-data', 'ssurgo-SPC.rds'))
  
}



getSoilData(s = 'coweeta')
getSoilData(s = 'clay-center')

getSoilData(s = 'sjer')
getSoilData(s = 'sfrec')


