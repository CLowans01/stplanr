# clustering analysis of full NI data set

# https://research.csiro.au/software/wp-content/uploads/sites/6/2015/02/Rspatialcourse_CMIS_PDF-Standard.pdf - ch23

# data standardisation

# join OD to SF object as in routing script


# density map o and d on same plot using the soa zones

qtm(zones_od, c("all", "all_dest")) +
  tm_layout(panel.labels = c("Origin", "Destination"))




# Each SOA centroid will have a mean distance to be travelled from it (as an origin). Interpolate this across a raster dataset?

# interpolate the st dev as a map


# for the cluster analysis - each od pair has a start and end coord, and a length - use distance between lines as the clustering item