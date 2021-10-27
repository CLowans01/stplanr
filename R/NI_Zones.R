library(sf)
library(ggplot2)
# create sf dataframe from Northern Ireland shapefile using st_read - "Read simple features from file or database, or retrieve layer names and their geometry type(s)"
NI_SOA <- st_read("C:\\Users\\40055486\\Desktop\\NI SOA & OD Files for R\\SOA2011.shp")

plot(NI_SOA)

# does this need reprojected to wgs84 to use the OSRM routing system?

# extract the data to a csv file to be used to relabel OD data
# at time of extraction from the web the od data is labelled, rather than soa coded
# using the soa code makes everything easier since the soa code is the first column of the NI_SOA sf data frame