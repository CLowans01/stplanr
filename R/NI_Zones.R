library(sf)
library(ggplot2)
# create sf dataframe from Northern Ireland shapefile
NI_SOA <- st_read("C:\\Users\\40055486\\Desktop\\NI SOA Files\\SOA2011.shp")

plot(NI_SOA)

# does this need reprojected to wgs84 to use the routing system?