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

# create desire lines

# is the data on mode available? if so, visualise by mode

# load the APIs

# OSRM for cars

# cycle streets.net for cycle lanes

# Use APIs to route

# Calc distances

# compare euclidean distance with route distances & compare fastest vs quietest etc.for current travel patterns

# catchment areas

# reproduce input data for new scenarios with new modes assigned -> either scenarios or run modal split model elsewhere

#rerunabove steps

#visualise new networks & calculate travel times using google maps API or cycle streets API -> post hoc process to find ebike speed?

# what are the new travel times of cars / buses with new levels of traffic?
# Implicitly assume services are accessible in omagh town and new travel times increase accessibility?