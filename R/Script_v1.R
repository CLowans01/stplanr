#C Lowans PhD work.
# Script V1
# citation for stplanr package:
# Lovelace, R. and Ellison, R., 2017. stplanr: A Package for Transport Planning. The R Journal.
# https://doi.org/10.32614/RJ-2018-053

#Load packages
library(stplanr)

if (!require("pacman")) install.packages("pacman")

#load any needed pacman packages
# pacman::p_load(pacman, rio, ..)

# install.packages("tidyverse")

# load OD data - also NB rename the data that you load - stplanr data has default names per intro vignette
# This bit not done with stplanr - need to clean and format etc

#
#' Although these variable names are unique to UK data, the data
#' structure is generalisable and typical of flow data from any source.
#' The key variables are the origin and destination ids, which link to
#' the `cents` georeferenced spatial objects.
#' @family example data
#' @examples
#' \dontrun{
#' # This is how the dataset was constructed - see
#' # https://github.com/npct/pct - if download to ~/repos
#' flow <- readRDS("~/repos/pct/pct-data/national/flow.Rds")
#' data(cents)
#' o <- flow$Area.of.residence %in% cents$geo_code[-1]
#' d <- flow$Area.of.workplace %in% cents$geo_code[-1]
#' flow <- flow[o & d, ] # subset flows with o and d in study area
#' library(devtools)
#' flow$id <- paste(flow$Area.of.residence, flow$Area.of.workplace)
#' use_data(flow, overwrite = TRUE)

# use od_id and od_oneway to pair a-b and b-a data


# create desire lines
#od2line
##od_data <- stplanr::flow[1:20, ]
##l <- od2line(flow = od_data, zones = cents_sf)
##plot(sf::st_geometry(cents_sf))
##plot(l, lwd = l$All / mean(l$All), add = TRUE)
##l <- od2line(flow = od_data, zones = cents)
## When destinations are different
##head(destinations[1:5])
##od_data2 <- flow_dests[1:12, 1:3]
##od_data2
##flowlines_dests <- od2line(od_data2, cents_sf, destinations = destinations_sf)
##flowlines_dests
##plot(flowlines_dests)

# is the data on mode available? if so, visualise by mode

# load the APIs

# OSRM for cars

# cycle streets.net for cycle lanes

# Use APIs to route

# Calc distances

# compare euclidean distance with route distances & compare fastest vs quietest etc.for current travel patterns.
# use linelabels

# catchment areas - calc_catchment_sum

# reproduce input data for new scenarios with new modes assigned -> either scenarios or run modal split model elsewhere

#rerunabove steps

#visualise new networks & calculate travel times using google maps API or cycle streets API or bikecitizens API -> post hoc process to find ebike speed? use overline function?

# what are the new travel times of cars / buses with new levels of traffic?
# Implicitly assume services are accessible in omagh town and new travel times increase accessibility?