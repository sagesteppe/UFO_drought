# Calculate Monthly Summary Statistics on Gridmet Data

#' Gridmet data are distributed as daily values. However, we do not always
#' want data of that fine a temporal grain, but may want a data set which 
#' PRISM or other sources do not have. Here is a simple function to computre
#' summary stats on gridmet data. 
#' 
#' @param inpath a relative or absolute path to a directory root containing the 
#'  gridMET data (this assuming you used get_gridmet.)
#' @param FUN the stat which you want to compute, standard from stats, e.g. mean, or sum. 
#' @param outpath dirctory where want to save these data to, will default to 
#' name a subdirectory from that path utilizing the variable name plus the stat. 
#' @param cropRast a path to a raster which we can use to crop the data. 
#' @param variable the gridMET variable to perform the operations on. 

#' first we create the appropriate dates, this can be and should be reduced
#' @example 
#' 
gridSTATS <- function(inpath, FUN, outpath, cropRast, variable){
  
  months_normal <- 1:365
  names(months_normal) <- dmonths_normal
  
  month_1st_last <- data.frame('MONTH' = dmonths_normal) %>% 
    rownames_to_column('DOY') %>% 
    mutate(DOY = as.numeric(DOY)) %>% 
    group_by(MONTH) %>% 
    filter(DOY == max(DOY) | DOY == min(DOY)) %>% 
    mutate(Year_type = 'normal')
  
  month_1st_last_LEAP <- data.frame('MONTH' = dmonths_leap) %>% 
    rownames_to_column('DOY') %>% 
    mutate(DOY = as.numeric(DOY)) %>% 
    group_by(MONTH) %>% 
    filter(DOY == max(DOY) | DOY == min(DOY)) %>% 
    mutate(Year_type = 'leap')
  
  periods <- data.frame('period' = rep(c('Start', 'End'), times = 24))
  
  months <- bind_rows(month_1st_last, month_1st_last_LEAP) %>% 
    bind_cols(., periods) %>% 
    pivot_wider(names_from = period, values_from = DOY)
  
  months_leap <- 1:366
  names(months_leap) <- dmonths_leap
  leap_yrs <- seq(from = 1980, to = 2020, by = 4)
  normal_yrs <- 1979:2021
  normal_yrs <- normal_yrs[! 1979:2021 %in% leap_yrs]
  normal_yrs <- setNames(normal_yrs, rep('normal', length(normal_yrs)))
  leap_yrs <- setNames(leap_yrs, rep('leap', length(leap_yrs)))
  
  yrs <- c(leap_yrs, normal_yrs)
  yrs <- yrs[order(yrs)]
  
  leapYearLookUp <- stack(yrs) %>% 
    mutate(days = if_else(ind == 'normal', 365, 366),
           toDOY = cumsum(days),
           fromDOY= if_else(ind == 'normal', toDOY - 364, toDOY - 365 )) %>% 
    select(Year = values, Year_type = ind, fromDOY, toDOY)  %>% 
    left_join(., months, by = 'Year_type') %>% 
    mutate(across(Start:End, ~ .x + fromDOY - 1))
  
  # now do the work
  
  rastIN <- rast(file.path(inpath, variable, (list.files(file.path(inpath, variable)))))
  
  cropRast <- rast(cropRast)
  if(crs(cropRast) != crs(rastIN)){
    message(paste0('Projecting the template raster to crop the gridMET stack.')) ;
    border <- project(rast(cropRast), crs(rastIN)) 
  } else {
    border <- cropRast
  }
  message('Projection complete, now cropping')
  rastIN <- crop(rastIN, border)
  message('Cropping complete, now calculating')
  
  rasta <- vector(mode = "list", length = nrow(leapYearLookUp))
  for (i in 1:nrow(leapYearLookUp)){
    rasta[[i]] <- 
      fchoice(FUN, x = rastIN[[leapYearLookUp[i,'Start']:leapYearLookUp[i,'End']]]) 
    }
  names(rasta) <- leapYearLookUp$MONTH
  rasta <- split(rasta, leapYearLookUp$Year)
  rasta <- lapply(rasta, rast)

  # write the results to disk.
  ifelse(!dir.exists(file.path(outpath)), 
         dir.create(file.path(outpath)), FALSE)
  ifelse(!dir.exists(file.path(outpath, variable)), 
         dir.create(file.path(outpath, variable)), FALSE)
  fnames <- file.path(outpath, variable, paste0(variable, '_', names(rasta), '.tif'))
  
  mapply(writeRaster, rasta, fnames, overwrite =T)
  message(paste0(variable, ' has finished processing and is saved as a stack'))
  
  return(rastIN)
}


#' global variable, days in a month - non leap year.
dmonths_normal <- c(
  rep('JAN', length(1:31)), rep('FEB', length(32:59)), rep('MAR', length(60:90)),
  rep('APR', length(91:120)), rep('MAY', length(121:151)), rep('JUN', length(152:181)),
  rep('JUL', length(182:212)), rep('AUG', length(213:243)), rep('SEPT', length(244:273)),
  rep('OCT', length(274:304)), rep('NOV', length(305:334)), rep('DEC', length(335:365)) )

#' global variable, days in a month - leap year.
dmonths_leap <- c(dmonths_normal[1:31], rep('FEB', 29), dmonths_normal[60:365])


#' update the names of rasters quickly
#' 
#' Simple function, mostly just to reduce the amounts of lines dedicated to this
#' process. Is useful if many different variables are being stacked and the only
#' distinguishing feature for them is the variable name and years. 
#' 
#' @param raster a stack for input
#' @param var optional, a different name for the variable, defaults to the name
#' of the stack
#' @param start numeric, start year
#' @param end numeric, end year
#' @examples 
#' 
#' names(vs)
#' names(vs) <- namer(vs)
#' names(vs)
#' @export
namer <- function(raster, var, start, end){
  if(missing(var)){var = deparse(substitute(raster))}
  if(missing(end)){end = (start -1) + dim(raster)[3]/12}
  names <- paste(var, names(raster), rep(start:end, each = 12) ,sep = "_")
}


#' Put reference potential evapotranspiration onto a gridded surface
#' 
#' the SPEI function is made to deal with non-explictely spatial data, and to not
#' deal with replicates cells. gross. we fix that here.
#' @param x a dataset with all of the metrics for calculating the Pet vars
#' @param rast a gridded surface for storing the values. We will return a stack 
#' of spatial and temporal values. 

PeTbyCell <- function(x, rast){
  y <- x %>% 
    pmap(~SPEI::penman(Tmin = x$tmin, Tmax = x$tmax,
                       U2 = x$vs, lat = x$y[1], #
                       Rs = NA, Ra = NA, # but could get  both from r.sun ??
                       tsun = x$sunhours, # CC = drought_vars$cloudcover,
                       z = x$elevation[1], na.rm = F)
    )  # super!!!! slow !!!! yeeba !
  
  # here need to determine WHICH cells were not in the complete cases !=, 
  # and remove these from the raster stack? and then project these values into a new pancake?
  
}

