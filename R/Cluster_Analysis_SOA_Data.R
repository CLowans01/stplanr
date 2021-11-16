#C Lowans PhD work.
#

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
#' citation for cluster detection method
#' @article{,
#'  author = {{Ran Tao} and {Jean-Claude Thill}},
#'   title = {{Spatial Cluster Detection in Spatial Flow Data}},
#'   year = {2016},
#'   volume = {48},
#'   journal = {{Geographical Analysis}},
#'   url = {https://doi.org/10.1111/gean.12100},
# Load libraries and packages ---------------------------------------------


library(stplanr)
library(osmdata)
library(osrm)
library(sf)
library(tidyverse)
library(ClusterR)
library(cluster)


# clustering analysis of full NI data set

# https://research.csiro.au/software/wp-content/uploads/sites/6/2015/02/Rspatialcourse_CMIS_PDF-Standard.pdf - ch23


# load OD flow data from csv into new object
OD_NI <- read_csv("C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\OD_Pairs_NI_geocoded.csv")


# OD Routing --------------------------------------------------------------

# run OD routing script down to desire lines part - need ODsfobj here
# OD_Routing.R...
# system("cmd.exe", input = paste('"C:\\Program Files\\R\\R-3.6.1\\bin\\Rscript.exe" C:\\Users\\nobody\\Documents\\R\\MyScript.R'))
# density map o and d on same plot using the soa zones as a check

qtm(OD_sfobj, c("all", "all_dest")) +
  tm_layout(panel.labels = c("Origin", "Destination"))


# O & D cluster analysis --------------------------------------------------



# Prepare distance matrix for flow cluster detection  ---------------------------------------------------




# prepare flow events as vectors -> Fi(Xi, Yi, Ui, Vi)

# Distance between Fi and Fj
# FDij = SQRT (C*((Xi-Xj)^2 + (Yi-Yj)^2)) + D*((Ui-Uj)^2 + (Vi-Vj)^2)) ) where C and D are weights, and by default C = D = 1, and sum to 2]
# where ((Xi-Xj)^2 + (Yi-Yj)^2)) can be written dO and ((Ui-Uj)^2 + (Vi-Vj)^2)) can be writted dD

# Flow dissimilarity is therefore
# FDSij = SQRT((C*dO^2 + D*dD^2)/(Li*Lj))
# where Li and Lj are the flow lengths

# Flow distance calculation -----------------------------------------------

# Find difference between Fi and Fj for all N flows = NxN matrix


# Clustering detection ----------------------------------------------------



# Statistical significance evaluation -------------------------------------


# Visualise ---------------------------------------------------------------


