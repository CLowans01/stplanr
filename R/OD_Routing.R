#C Lowans PhD work.


# Intro and citations -----------------------------------------------------

# citation for stplanr package:
#' @Article{,
#'   author = {{Robin Lovelace} and {Richard Ellison}},
#'   title = {{stplanr: A Package for Transport Planning}},
#'   year = {2018},
#'   volume = {10},
#'   number = {2},
#'   journal = {{The R Journal}},
#'   url = {https://doi.org/10.32614/RJ-2018-053},
#' }
#'
#' citation for Geocomputation book
#' @book{lovelace_geocomputation_2019,
#'   title = {Geocomputation with {{R}}},
#'   isbn = {1-138-30451-4},
#'   abstract = {Book on geographic data with R.},
#'   publisher = {{CRC Press}},
#'   author = {Lovelace, Robin and Nowosad, Jakub and Muenchow, Jannes},
#'   year = {2019}
#' }
# Load libraries and packages ---------------------------------------------

# if (!require("stplanr")) install.packages("stplanr")
# install.packages("readxl")
library(stplanr)
library(osmdata)
library(osrm)
library(sf)
library(tidyverse)
library(tmap)

# Load OD and Zone data ------------------------------------------------------------

# taken from geocomp 12 bristol help

# load OD flow data from csv into new object
OD_NI <- read_csv("C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\OD_Pairs_NI_geocoded.csv")

# create sf dataframe from Northern Ireland shapefile using st_read
NI_SOA <- st_read("C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\SOA2011.shp")

# plot to check if needed
 plot(NI_SOA)

# Geographically subset OD data -------------------------------------------
# https://github.com/Robinlovelace/geocompr/blob/main/code/12-desire.R

# create bristol od from full OD data set
# bristol_od = od_all %>%
# select(o = `Area of residence`, d = `Area of workplace`,
#        all = `All categories: Method of travel to work`,
#        bicycle = Bicycle, foot = `On foot`,
#        car_driver = `Driving a car or van`, train = Train) %>%
#   filter(o %in% bristol_zones$geo_code & d %in% bristol_zones$geo_code, all > 19)
# summary(bristol_zones$geo_code %in% bristol_od$d)
# summary(bristol_zones$geo_code %in% bristol_od$o)

# OD Manipulation to create arguments for OD2line function  -----------------------------------------------------

# there are many more rows in the OD data than the SOA data, so the OD data must be aggregated

# call the new object zones_attr - a data frame with rows representing zones and an ID variable.
zones_attr <- OD_NI %>% # subititute for geographical subset if needed
  # group by origin zone
  group_by(o) %>%
# Group to find number of unique codes and aggregate the trips to the origin codes -> no destinations in this new object
  summarize_if(is.numeric, sum) %>%
  # rename grouping variable to match the ID column SOA_Code in the NI_SOA object -> so now all origins are grouped by code
  dplyr::rename(SOA_CODE = o)

# # The resulting object zones_attr is joinable to the NI SOA object
# #  verify that the IDs match those in the zones dataset :
 summary(zones_attr$SOA_CODE %in% NI_SOA$SOA_CODE)

# if true, all 890 zones from NI_SOA are present in the new object and that zone_attr is in a form that can be joined onto the NI SOA object.
# if false, the step hasnt worked and needs checked

# now join zones and zones attr
zones_joined <- left_join(NI_SOA, zones_attr, by = "SOA_CODE")
# now we have code, label, number of times a zone is an origin, and the geometry

# checks
sum(zones_joined$all) # how many trips
names(zones_joined) # file headings

# OD_sfobj, the spatial object for the od2line function is created by aggregating information about destination as well
OD_sfobj <- OD_NI %>%
  group_by(d) %>% # group by column d
  summarize_if(is.numeric, sum) %>% # sum across the grouping
  dplyr::select(SOA_CODE = d, all_dest = all) %>% # subset columns using names and types
  inner_join(zones_joined, ., by = "SOA_CODE") # use inner join function to join zones by geocode

# OD_sfobj is now an sf data frame for use in od2line function -> contains code, label, number of times a zone is an origin, number of times
# a zone is a destination, and the zone geometry

# quick plot a heat map of Os and Ds

qtm(OD_sfobj, c("all", "all_dest")) +
  tm_layout(panel.labels = c("Origin", "Destination"))

# Create desire lines -----------------------------------------------------

# filter out intra zonal travel into a new variable
od_intra <- filter(OD_NI, o == d)
od_inter <- filter(OD_NI, o != d)

# create desire lines excluding intra zonal travel
desire_lines <- od2line(od_inter, OD_sfobj)

# desire lines with intra zonal travel included
# All_desire_lines <-od2line(OD_NI, OD_sfobj) # nb the output here excludes distance - not sure why, so not useful. Possibly because some outcomes have dist = 0?

# plot -> edit this because its plotting the "all" twice
tmap_mode("plot")
tm_shape(desire_lines)  +
  tm_lines(palette = "Pastel1", breaks = c(0, 10, 25, 100, 400),
           lwd = "all",
           scale = 9,
           title.lwd = "Number 1",
           alpha = 0.6,
           col = "all",
           title = "Number of trips"
  ) +
  tm_scale_bar()

# is the data on mode available? if so, visualise by mode
# qtm(desire_lines, lines.lwd = "all")

# export desire lines to run calcs in xlsx
# in excel, the mean distance travelled for each origin zone is found - data then reloaded and a raster map drawn
write.csv(desire_lines, "C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\Desire_Lines_Raw.csv")

# Trips under a set distance  -----------------------------------------------------------------

# use geographic subset

# calculates the distance (i.e. length) of each desire line
desire_lines$distance = as.numeric(st_length(desire_lines))
# attribute filter to create new object from desire lines less than 5km distance
desire_short = dplyr::filter(desire_lines, distance < 5000)
# create new sf objects representing the routes that have just been filtered out, and route using OSRM
# route_short = route(l = desire_short, route_fun = route_osrm)

# The following command makes use of the ability of simple features objects to contain multiple geographic columns:
# This allows plotting the desire lines along which many short car journeys take place alongside likely routes
# traveled by cars by referring to each geometry column separately (desire_carshort$geometry and desire_carshort$geom_car in this case)
# desire_short$geom_car = st_geometry(route_short)

# plot desire lines and routes that we've just calculated
plot(st_geometry(desire_short))
# plot(desire_carshort$geom_car, col = "red", add = TRUE)
plot(st_geometry(st_centroid(OD_sfobj)), add = TRUE)

# Distance ----------------------------------------------------------------



# Calc distances

# compare euclidean distance with route distances & compare fastest vs quietest etc.for current travel patterns.
# use linelabels



# Catchment ---------------------------------------------------------------


# catchment areas - calc_catchment_sum

# if ican get a raster of elevation then i can add a line and extract elevation change along the line - see 5.4.2 in geocomp with R

# reproduce input data for new scenarios with new modes assigned -> either scenarios or run modal split model elsewhere

#rerunabove steps

#visualise new networks & calculate travel times using google maps API or cycle streets API or bikecitizens API -> post hoc process to find ebike speed? use overline function?


# Analysis ----------------------------------------------------------------



# what are the new travel times of cars / buses with new levels of traffic?
# Implicitly assume services are accessible in omagh town and new travel times increase accessibility?