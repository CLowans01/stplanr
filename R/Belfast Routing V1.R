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
Belfast <- st_read("C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\Belfast.shp")

# plot to check if needed
plot(Belfast)

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
  # rename grouping variable to match the ID column SOA_Code in the Belfast object -> so now all origins are grouped by code
  dplyr::rename(SOA_CODE = o)

# # The resulting object zones_attr is joinable to the NI SOA object
# #  verify that the IDs match those in the zones dataset :
summary(zones_attr$SOA_CODE %in% Belfast$SOA_CODE)

# if true, all x zones from Belfast are present in the new object and that zone_attr is in a form that can be joined onto the NI SOA object.
# if false, the step hasnt worked entirely and needs checked for fatal errors or stuff

# now join zones and zones attr
zones_joined <- left_join(Belfast, zones_attr, by = "SOA_CODE")
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

# extract from od_inter only those codes that are present in Belfast shp file
OD_Belfast <- od_inter %>%
  filter(od_inter$o %in% Belfast$SOA_CODE) %>%
  filter(od_inter$d %in% Belfast$SOA_CODE)

# create desire lines excluding intra zonal travel
desire_lines <- od2line(OD_Belfast, OD_sfobj)

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
