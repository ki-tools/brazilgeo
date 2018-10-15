ff <- list.files("_ignore/municipalities/data", full.names = TRUE)
muni_shp <- lapply(ff, geogrid::read_polygons)
names(muni_shp) <- gsub(".*\\/(.*)\\.json", "\\1", ff)
st_shp <- muni_shp$Brasil
muni_shp$Brasil <- NULL
muni_shp <- do.call(rbind, muni_shp)
# sp::plot(muni_shp)
names(muni_shp)

head(muni_shp@data)
names(muni_shp@data) <- c("muni_code", "name", "state_abbrev")
muni_shp$country_code <- "BRA"

row.names(muni_shp@data) <- sapply(slot(muni_shp, "polygons"), function(x) slot(x, "ID"))
# muni_shp2 <- rgeos::gSimplify(muni_shp, tol = 0.05, topologyPreserve = TRUE)
# muni_shp3 <- sp::SpatialPolygonsDataFrame(muni_shp2, muni_shp@data)
muni_shp3 <- muni_shp

object.size(muni_shp) / object.size(muni_shp3)
# nearly 2x reduction

tmp <- muni_shp3@data
tmp$muni_code <- as.character(tmp$muni_code)
tmp$name <- as.character(tmp$name)

tmp2 <- tmp %>%
  select(-state_abbrev, country_code) %>%
  left_join(br_muni_codes)

idx <- which(tmp2$name != tmp2$muni_name)
tmp2[idx, c("name", "muni_name")]
tmp2 <- select(tmp2, -name)

muni_shp3@data <- tmp2

br_muni_geo <- muni_shp3

use_data(br_muni_geo, overwrite = TRUE, compress = "xz")



# code_lookup <- c(
#   "GO" = "BRA-1294",
#   "SP" = "BRA-1311",
#   "PE" = "BRA-1313",
#   "AC" = "BRA-576",
#   "AM" = "BRA-592",
#   "MA" = "BRA-593",
#   "PA" = "BRA-594",
#   "RO" = "BRA-595",
#   "TO" = "BRA-596",
#   "DF" = "BRA-599",
#   "MS" = "BRA-600",
#   "MG" = "BRA-601",
#   "MT" = "BRA-602",
#   "RS" = "BRA-612",
#   "PR" = "BRA-613",
#   "SC" = "BRA-614",
#   "CE" = "BRA-621",
#   "PI" = "BRA-622",
#   "AL" = "BRA-623",
#   "BA" = "BRA-624",
#   "ES" = "BRA-625",
#   "PB" = "BRA-626",
#   "RJ" = "BRA-627",
#   "RN" = "BRA-628",
#   "SE" = "BRA-629",
#   "RR" = "BRA-670",
#   "AP" = "BRA-681"
# )

# muni_shp$state_abbrev <- as.character(muni_shp$state_abbrev)

# muni_shp$state_code <- unname(code_lookup[muni_shp$state_abbrev])

# brazil_munis <- muni_shp

# brazil_munis$muni_code <- as.character(brazil_munis$muni_code)
# brazil_munis$name <- as.character(brazil_munis$name)

# use_data(brazil_munis, overwrite = TRUE, compress = "xz")

