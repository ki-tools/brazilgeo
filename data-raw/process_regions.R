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
  muni_code = c("1504752", "2206720", "4220000", "4212650", "4314548", "5006275"),
  muni_name = c("Mojuí dos Campos", "Nazária", "Balneário Rincão", "Pescaria Brava", "Pinto Bandeira", "Paraíso das Águas"),
  state_code = c("PA", "PI", "SC", "SC", "RS", "MT")
)

muni_codes2 <- bind_rows(muni_codes, new_munis)

d2 <- left_join(d, muni_codes2, by = "muni_code")

length(which(is.na(d2$muni_name.x)))
length(which(is.na(d2$muni_name.y)))

d2 <- left_join(d,
  select(muni_codes2, -muni_name),
  by = "muni_code")

d3 <- left_join(d2, state_codes, by = "state_code")

tmp <- data_frame(
  muni_code = as.character(brazil_munis$muni_code),
  state_code2 = brazil_munis$state_code
)

d4 <- left_join(d3, tmp)

muni_codes <- select(d4,
  muni_name, muni_code, micro_name, micro_code,
  meso_name, meso_code, state_name, state_code, 
  state_code2, region_name, region_code)

use_data(muni_codes, overwrite = TRUE)
