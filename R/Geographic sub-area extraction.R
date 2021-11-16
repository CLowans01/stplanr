library(stplanr)
library(osmdata)
library(osrm)
library(sf)
library(tidyverse)
library(tmap)


Omagh_region <- getbb("Omagh", format_out = "sf_polygon") %>%
                   st_set_crs(4326) %>%
                   st_sf(data_frame(Name = "Omagh (OSM)"), geometry = .$geometry)

mapview::mapview(Omagh_region)

bristol_cents = st_centroid(msoa2011_vsimple)[bristol_ttwa, ]
plot(bristol_cents$geometry)
bristol_zones = msoa2011_vsimple[msoa2011_vsimple$msoa11cd %in% bristol_cents$msoa11cd, ] %>%
  select(geo_code = msoa11cd, name = msoa11nm) %>%
  mutate_at(1:2, as.character)