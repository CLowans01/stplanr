#C Lowans PhD work.
# Script V1

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


#Load packages
# if (!require("stplanr")) install.packages("stplanr")
library(stplanr)
library(osmdata)
library(osrm)
# Load libraries and packages ---------------------------------------------


if (!require("pacman")) install.packages("pacman")

#load any needed pacman packages
# pacman::p_load(pacman, rio, ..)

# install.packages("tidyverse")

# load OD data - also NB rename the data that you load - stplanr data has default names per intro vignette
# This bit not done with stplanr - need to clean and format etc

# Load OD data ------------------------------------------------------------

# u = "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/536823/local-area-walking-and-cycling-in-england-2015.zip"
# download.file(u, "local-area-walking-and-cycling-in-england-2015.zip")
# unzip("local-area-walking-and-cycling-in-england-2015.zip")
# View(readODS::read_ods("Table index.ods"))
# cw0103 = readODS::read_ods("cw0103.ods")
# View(cw0103)
# ```

# or
# # using wicid open data - see http://wicid.ukdataservice.ac.uk/
# unzip("~/Downloads/wu03ew_v2.zip")
# od_all = read_csv("wu03ew_v2.csv")
# file.remove("wu03ew_v2.csv")
# od = od_all %>%
#   select(o = `Area of residence`, d = `Area of workplace`, all = `All categories: Method of travel to work`, bicycle = Bicycle, foot = `On foot`, car_driver = `Driving a car or van`, train = Train) %>%
#   filter(o %in% zones$geo_code & d %in% zones$geo_code, all > 19)
# summary(zones$geo_code %in% od$d)
# summary(zones$geo_code %in% od$o)


# use od_id and od_oneway to pair a-b and b-a data





# Create OD sf object -----------------------------------------------------
#
# #To add travel data, we will undertake an attribute join,
# # a common task described in Section 3.2.3.
# # We will use travel data from the UK’s 2011 census question on travel to work, data stored in bristol_od,

# # create bristol od from full OD data set
# bristol_od = od_all %>%
# select(o = `Area of residence`, d = `Area of workplace`,
#        all = `All categories: Method of travel to work`,
#        bicycle = Bicycle, foot = `On foot`,
#        car_driver = `Driving a car or van`, train = Train) %>%
#   filter(o %in% bristol_zones$geo_code & d %in% bristol_zones$geo_code, all > 19)
# summary(bristol_zones$geo_code %in% bristol_od$d)
# summary(bristol_zones$geo_code %in% bristol_od$o)

# create geographic zones
# bristol_cents = st_centroid(msoa2011_vsimple)[bristol_ttwa, ]
# plot(bristol_cents$geometry)
# bristol_zones = msoa2011_vsimple[msoa2011_vsimple$msoa11cd \%in\% bristol_cents$msoa11cd, ] \%>\%
#   select(geo_code = msoa11cd, name = msoa11nm) \%>\%
#   mutate_at(1:2, as.character)
# plot(bristol_zones$geometry, add = TRUE)



# # The first column is the ID of the zone of origin and the second column is the zone of destination.
# # bristol_od has more rows than bristol_zones, representing travel between zones rather than the zones themselves:
# nrow(bristol_od)
#
# nrow(bristol_zones)
#
# # The results of the previous code chunk shows that there are more than 10 OD pairs for every zone,
# # meaning we will need to aggregate the origin-destination data before it is joined with bristol_zones
#
# # The next chunk grouped the data by zone of origin (contained in the column o);
# # aggregated the variables in the bristol_od dataset if they were numeric, to find the total number of people living in each zone by mode of transport;
# # renamed the grouping variable o so it matches the ID column geo_code in the bristol_zones object.
#
# zones_attr = bristol_od %>%
#   group_by(o) %>%
#   summarize_if(is.numeric, sum) %>%
#   dplyr::rename(geo_code = o)
#
# # The resulting object zones_attr is a data frame with rows representing zones and an ID variable.
# # We can verify that the IDs match those in the zones dataset using the %in% operator as follows:
# summary(zones_attr$geo_code %in% bristol_zones$geo_code)
#
# # The results show that all 102 zones are present in the new object and that zone_attr is in a form that can be joined onto the zones.
# # This is done using the joining function left_join() (note that inner_join() would produce here the same result):
#
# zones_joined = left_join(bristol_zones, zones_attr, by = "geo_code")
# sum(zones_joined$all)
#
# names(zones_joined)

# The result is zones_joined, which contains new columns representing the total number of trips originating in each zone in the study area (almost 1/4 of a million)
# and their mode of travel (by bicycle, foot, car and train).

# OD_sfobj, the spatial object for the od2line function is created by aggregating information about destination zones

# OD_sfobj = OD_data %>%
#   group_by(d) %>% # group by column d
#   summarize_if(is.numeric, sum) %>% # summarise columns if they are numeric, sum them
#   dplyr::select(geo_code = d, all_dest = all) %>% # subset columns using names and types
#   inner_join(zones_joined, ., by = "geo_code") # use inner join function to join zones by geocode

# OD_sfobj is now an sf data frame




# Create desire lines -----------------------------------------------------

# create desire lines
# desire_lines = od2line(OD_data, OD_sfobj)


# is the data on mode available? if so, visualise by mode


# Routing -----------------------------------------------------------------


# load the APIs

# OSRM for cars

# cycle streets.net for cycle lanes

# Use APIs to route


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