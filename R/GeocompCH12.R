library(sf)
library(dplyr)
library(spDataLarge)
library(stplanr)      # geographic transport data package
library(tmap)         # visualization package (see Chapter 8)


# The 102 zones used in this chapter are stored in bristol_zones
# bristol_zones contains no attribute data on transport, however, only the name and code of each zone:
names(bristol_zones)

# Transport zones ---------------------------------------------------------



#To add travel data, we will undertake an attribute join,
# a common task described in Section 3.2.3.
# We will use travel data from the UK’s 2011 census question on travel to work, data stored in bristol_od,

# The first column is the ID of the zone of origin and the second column is the zone of destination.
# bristol_od has more rows than bristol_zones, representing travel between zones rather than the zones themselves:
nrow(bristol_od)

nrow(bristol_zones)

# The results of the previous code chunk shows that there are more than 10 OD pairs for every zone,
# meaning we will need to aggregate the origin-destination data before it is joined with bristol_zones

# The next chunk grouped the data by zone of origin (contained in the column o);
# aggregated the variables in the bristol_od dataset if they were numeric, to find the total number of people living in each zone by mode of transport;
# renamed the grouping variable o so it matches the ID column geo_code in the bristol_zones object.

zones_attr = bristol_od %>%
  group_by(o) %>%
  summarize_if(is.numeric, sum) %>%
  dplyr::rename(geo_code = o)

# The resulting object zones_attr is a data frame with rows representing zones and an ID variable.
# We can verify that the IDs match those in the zones dataset using the %in% operator as follows:
summary(zones_attr$geo_code %in% bristol_zones$geo_code)

# The results show that all 102 zones are present in the new object and that zone_attr is in a form that can be joined onto the zones.
# This is done using the joining function left_join() (note that inner_join() would produce here the same result):

zones_joined = left_join(bristol_zones, zones_attr, by = "geo_code")
sum(zones_joined$all)

names(zones_joined)

# The result is zones_joined, which contains new columns representing the total number of trips originating in each zone in the study area (almost 1/4 of a million)
# and their mode of travel (by bicycle, foot, car and train).


# zones_od, which contains a new column reporting the number of trip destinations by any mode, is created as follows:

zones_od = bristol_od %>%
  group_by(d) %>% # group by column d
  summarize_if(is.numeric, sum) %>% # summarise columns if they are numeric, sum them
  dplyr::select(geo_code = d, all_dest = all) %>% # subset columns using names and types
  inner_join(zones_joined, ., by = "geo_code") # use inner join function to join zones by geocode

# zones_od is an sf data frame
# recall -  an sf object is a collection of simple features that includes attributes and geometries in the form of a data frame
# it is a data frame (or tibble) with rows of features, columns of attributes, and a special geometry column that contains the spatial aspects of the features
# The special geometry column is itself a list of class sfc, which is made up of individual objects of class sfg.


# a simple map
qtm(zones_od, c("all", "all_dest")) +
  tm_layout(panel.labels = c("Origin", "Destination"))



# Desire lines ------------------------------------------------------------

# more in depth work on the bristol_od data set
# To arrange the OD data by all trips and then filter-out only the top 5, to get a quick feel
od_top5 = bristol_od %>%
  arrange(desc(all)) %>%
  top_n(5, wt = all)

# The following command calculates the percentage of each desire line that is made by these active modes

bristol_od$Active = (bristol_od$bicycle + bristol_od$foot) /
  bristol_od$all * 100

# The following code chunk splits od_bristol into intra and inter zonal types:

od_intra = filter(bristol_od, o == d)
od_inter = filter(bristol_od, o != d)


# The next step is to convert the interzonal OD pairs into an sf object representing
# desire lines that can be plotted on a map with the stplanr function od2line()
# od2line creates a spatial (linestring) object (an sf object)
# It takes data frame containing origin and destination cones (flow) that match the first column in a a spatial (polygon or point) object (zones)
# so what we've done is use od_inter as the first argument, filtering out intrazone tripsand using this as our flow data
# and zones_od as the spatial object representing origins and destinations
desire_lines = od2line(od_inter, zones_od)

# visualise
qtm(desire_lines, lines.lwd = "all")


# Routing -----------------------------------------------------------------

# Instead of routing all desire lines generated in the previous section, which would be time and memory-consuming,
# we will focus on the desire lines of policy interest.

# We will therefore only route desire lines along which a high (300+) number of car trips take place that are up to 5 km in distance.
# The benefits of cycling trips are greatest when they replace car trips
# This routing is done in the code chunk below by the stplanr function route(),
# which creates sf objects representing routes on the transport network, one for each desire line.

desire_lines$distance = as.numeric(st_length(desire_lines)) # recall the $ operator can be used to select a variable/column
# also note st_length() determines the length of a linestring
desire_carshort = dplyr::filter(desire_lines, car_driver > 300 & distance < 5000) # subset rows using column values by calling dplyr filter function

route_carshort = route(l = desire_carshort, route_fun = route_osrm)

# We could keep the new route_carshort object separate from the straight line representation of the same trip in desire_carshort
# but, from a data management perspective, it makes more sense to combine them: they represent the same trip.

# The new route dataset contains distance (referring to route distance this time) and duration fields (in seconds) which could be useful.
# however, for the purposes of this chapter, we are only interested in the geometry, from which route distance can be calculated.

# The following command makes use of the ability of simple features objects to contain multiple geographic columns:
# This allows plotting the desire lines along which many short car journeys take place alongside likely routes
# traveled by cars by referring to each geometry column separately (desire_carshort$geometry and desire_carshort$geom_car in this case)
desire_carshort$geom_car = st_geometry(route_carshort)

# plot desire lines and routes that we've just calculated
plot(st_geometry(desire_carshort))
plot(desire_carshort$geom_car, col = "red", add = TRUE)
plot(st_geometry(st_centroid(zones_od)), add = TRUE)

# plot on an interactive map
mapview::mapview(desire_carshort$geom_car)


# Nodes -------------------------------------------------------------------

# We will use railway stations to illustrate public transport nodes, in relation to the research question of increasing cycling in Bristol.
# These stations are provided by spDataLarge in bristol_stations.

# The first stage is to identify the desire lines with most public transport travel,
# which in our case is easy because our previously created dataset desire_lines already contains a variable describing the number of trips by train

# To make the approach easier to follow, we will select only the top three desire lines in terms of rails use:
desire_rail = top_n(desire_lines, n = 3, wt = train)

# The challenge now is to ‘break-up’ each of these lines into three pieces, representing travel via public transport nodes.
# This can be done by converting a desire line into a multiline object consisting of three line geometries
# representing origin, public transport and destination legs of the trip

# This operation can be divided into three stages: matrix creation (of origins, destinations and the ‘via’ points representing rail stations),
# identification of nearest neighbors and conversion to multilines. These are undertaken by line_via().
# This stplanr function takes input lines and points and returns a copy of the desire lines
# — see the Desire Lines Extended vignette on the geocompr.github.io website and ?line_via for details on how this works.
# The output is the same as the input line, except it has new geometry columns representing the journey via public transport nodes, as demonstrated below:

ncol(desire_rail)

desire_rail = line_via(desire_rail, bristol_stations)
ncol(desire_rail)

# the initial desire_rail lines now have three additional geometry list columns representing travel from home to the origin station,
# from there to the destination, and finally from the destination station to the destination.



# Route networks ----------------------------------------------------------

# The data used in this section was downloaded using osmdata. To avoid having to request the data from OSM repeatedly,
# we will use the bristol_ways object, which contains point and line data for the case study area (see ?bristol_ways):


# As mentioned, route networks can usefully be represented as mathematical graphs,
# with nodes on the network connected by edges. A number of R packages have been developed for dealing with such graphs,
# notably igraph. One can manually convert a route network into an igraph object, but the geographic attributes will be lost.
# To overcome this issue SpatialLinesNetwork() was developed in the stplanr package to represent route networks simultaneously
# as graphs and a set of geographic lines. This function is demonstrated below using a subset of the bristol_ways object used in previous sections.

ways_freeway = bristol_ways %>% filter(maxspeed == "70 mph")
ways_sln = SpatialLinesNetwork(ways_freeway)

slotNames(ways_sln)

weightfield(ways_sln)

class(ways_sln@g)

# The output of the previous code chunk shows that ways_sln is a composite object with various ‘slots.’
# These include: the spatial component of the network (named sl), the graph component (g) and the ‘weightfield,’
# the edge variable used for shortest path calculation (by default segment distance). ways_sln is of class sfNetwork,
# defined by the S4 class system. This means that each component can be accessed using the @ operator,
# which is used below to extract its graph component and process it using the igraph package, before plotting the results in geographic space.

# In the example below, the ‘edge betweenness’, meaning the number of shortest paths passing through each edge, is calculated
# (see ?igraph::betweenness for further details and Figure 12.6).
# The results demonstrate that each graph edge represents a segment:
# the segments near the center of the road network have the greatest betweenness scores

e = igraph::edge_betweenness(ways_sln@g)
plot(ways_sln@sl$geometry, lwd = e / 500)

# One can also find the shortest route between origins and destinations using this graph representation of the route network.
# This can be done with functions such as sum_network_routes() from stplanr, which undertakes ‘local routing’ (see Section 12.5).


# Prioritising new infrastructure -----------------------------------------

# adds the car-dependent routes in route_carshort with a newly created object,
# route_rail and creates a new column representing the amount of travel along the centroid-to-centroid desire lines they represent
#  this now shows routes with high levels of car dependency and highlights opportunities for cycling rail stations

route_rail = desire_rail %>%
  st_set_geometry("leg_orig") %>%
  route(l = ., route_fun = route_osrm) %>%
  select(names(route_carshort))

route_cycleway = rbind(route_rail, route_carshort)
route_cycleway$all = c(desire_rail$all, desire_carshort$all)

# visualise
qtm(route_cycleway, lines.lwd = "all")
