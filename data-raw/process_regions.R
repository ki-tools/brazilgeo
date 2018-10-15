# https://ww2.ibge.gov.br/home/geociencias/geografia/default_div_int.shtm?c=1
# https://cidades.ibge.gov.br/brasil/se/aracaju/panorama

library(dplyr)

load("_ignore/regions/state_muni_codes.Rdata")

d <- readxl::read_xlsx("_ignore/regions/regioes_geograficas_composicao_por_municipios_2017_20180911.xlsx")

length(unique(d$cod_rgi))
length(unique(d$cod_rgint))

names(d) <- c("muni_name", "muni_code", "micro_code", "micro_name", "meso_code", "meso_name")

d2 <- left_join(d, muni_codes, by = "muni_code")

length(which(is.na(d2$muni_name.x)))
length(which(is.na(d2$muni_name.y)))

idx <- which(d2$muni_name.x != d2$muni_name.y)
d2[idx, c("muni_name.x", "muni_name.y")]

d2 <- left_join(d,
  select(muni_codes, -muni_name),
  by = "muni_code")

filter(d2, is.na(state_code)) %>%
  select(muni_name, muni_code)

# 1 Mojuí dos Campos   - Pará
# 2 Nazária            - Piauí
# 3 Balneário Rincão   - Santa Catarina (2013)
# 4 Pescaria Brava     - Santa Catarina (2013)
# 5 Pinto Bandeira     - Rio Grande do Sul (2015)
# 6 Paraíso das Águas  - Mato Grosso

new_munis <- data_frame(
  muni_code = c("1504752", "2206720", "4220000",
    "4212650", "4314548", "5006275"),
  muni_name = c("Mojuí dos Campos", "Nazária", "Balneário Rincão",
    "Pescaria Brava", "Pinto Bandeira", "Paraíso das Águas"),
  state_code = c("PA", "PI", "SC", "SC", "RS", "MS")
)

muni_codes2 <- bind_rows(muni_codes, new_munis)

d2 <- left_join(d, muni_codes2, by = "muni_code")

length(which(is.na(d2$muni_name.x)))
length(which(is.na(d2$muni_name.y)))

d2 <- left_join(d,
  select(muni_codes2, -muni_name),
  by = "muni_code")

d3 <- left_join(d2, state_codes, by = "state_code")

load("data/brazil_munis.rda")

tmp <- data_frame(
  muni_code = as.character(brazil_munis$muni_code),
  state_code2 = brazil_munis$state_code
)

tmp <- tmp[!duplicated(tmp),]

d4 <- left_join(d3, tmp)

muni_codes <- select(d4,
  muni_name, muni_code, micro_name, micro_code,
  meso_name, meso_code, state_name, state_code, 
  state_code2, region_name, region_code)

idx <- which(is.na(muni_codes$state_code2))

tmp <- muni_codes %>%
  group_by(state_code, state_code2) %>%
  summarise(n = n()) %>%
  filter(!is.na(state_code2))

tmp2 <- tmp$state_code2
names(tmp2) <- tmp$state_code

muni_codes$state_code2[idx] <- unname(tmp2[muni_codes$state_code[idx]])

br_muni_codes <- muni_codes
use_data(br_muni_codes, overwrite = TRUE)

micro_codes <- muni_codes %>%
  select(-muni_name, -muni_code) %>%
  group_by(micro_name, micro_code, meso_name, meso_code,
    state_name, state_code, state_code2, region_name, region_code) %>%
  summarise(n = n()) %>%
  select(-n)

br_micro_codes <- micro_codes
use_data(br_micro_codes, overwrite = TRUE)

meso_codes <- muni_codes %>%
  select(-muni_name, -muni_code, -micro_name, -micro_code) %>%
  group_by(meso_name, meso_code, state_name, state_code,
    state_code2, region_name, region_code) %>%
  summarise(n = n()) %>%
  select(-n)

br_meso_codes <- meso_codes
use_data(br_meso_codes, overwrite = TRUE)

state_codes <- muni_codes %>%
  select(-muni_name, -muni_code, -micro_name, -micro_code,
    -meso_name, -meso_code) %>%
  group_by(state_name, state_code,
    state_code2, region_name, region_code) %>%
  summarise(n = n()) %>%
  select(-n)

br_state_codes <- state_codes
use_data(br_state_codes, overwrite = TRUE)

######

shpint <- rgdal::readOGR("_ignore/regions/RG2017_rgint_20180911")
shpint2 <- rgeos::gSimplify(shpint, tol = 0.05, topologyPreserve = TRUE)

tmp <- shpint@data
tmp$rgint <- as.character(tmp$rgint)
tmp$nome_rgint <- as.character(tmp$nome_rgint)
names(tmp) <- c("meso_code", "name")
tmp2 <- left_join(tmp, br_meso_codes)
idx <- which(tmp2$name != tmp2$meso_name)
tmp2 <- select(tmp2, -name)
row.names(tmp2) <- sapply(slot(shpint2, "polygons"), function(x) slot(x, "ID"))

br_meso_geo <- sp::SpatialPolygonsDataFrame(shpint2, tmp2)
object.size(shpint) / object.size(br_meso_geo)
use_data(br_meso_geo, overwrite = TRUE)

shpi <- rgdal::readOGR("_ignore/regions/RG2017_rgi_20180911")
shpi2 <- rgeos::gSimplify(shpi, tol = 0.05, topologyPreserve = TRUE)

tmp <- shpi@data
tmp$rgi <- as.character(tmp$rgi)
tmp$nome_rgi <- as.character(tmp$nome_rgi)
names(tmp) <- c("micro_code", "name")
tmp2 <- left_join(tmp, br_micro_codes)
idx <- which(tmp2$name != tmp2$micro_name)
tmp2 <- select(tmp2, -name)
row.names(tmp2) <- sapply(slot(shpi2, "polygons"), function(x) slot(x, "ID"))

br_micro_geo <- sp::SpatialPolygonsDataFrame(shpi2, tmp2)
object.size(shpi) / object.size(br_micro_geo)
use_data(br_micro_geo, overwrite = TRUE)

