# Clean environment ------------------------------------------------------------
rm(list = ls())

# Library and System -----------------------------------------------------------

# Installation
pack_to_install <- c("dplyr", "tidyr")
if (length(which(!(pack_to_install %in% rownames(installed.packages())))) > 0) {
  pack_to_install <- pack_to_install[which(!(pack_to_install %in%
                                               rownames(installed.packages())))]
  install.packages(pack_to_install)
}

# Library
library(dplyr)     # for data frame management
library(tidyr)

# Prerequisite -----------------------------------------------------------------
# Source utils function
source("./src/target-data_utils.R")

# Location information
model_location <- read.csv("./auxiliary-data/data-locations/locations.csv")
abbr2location <- setNames(c(model_location$location_name, "US"),
                          c(model_location$abbreviation, "USA"))
location2number <- setNames(c(model_location$location, "US"),
                            c(model_location$location_name, "United States"))


# NHSN Hospitalization Data ----------------------------------------------------
df_nhsn <- extract_nhsn(hosp_report = TRUE, pathogen = "Influenza") |>
  standard_nhsn(location2number, abbr2location) |>
  dplyr::mutate(target = "inc hosp")

# ED Visit ---------------------------------------------------------------------
cdc_api <- "https://data.cdc.gov/api/views/"
df_ed_demo <- read.csv(paste0(cdc_api,
                              "7xva-uux8/rows.csv?&accessType=DOWNLOAD")) |>
  dplyr::filter(demographics_type == "Age Group", pathogen == "Influenza") |>
  dplyr::mutate(
    age_group =
      dplyr::case_when(demographics_values == "0-4 years" ~ "0-4",
                       demographics_values == "5-17 years" ~ "5-17",
                       demographics_values == "65+ years" ~ "65-130",
                       demographics_values == "18-64 years" ~ "18-64"),
    target = "% ed visit", location = "US") |>
  dplyr::select(location, date = week_end, observation = percent_visits,
                age_group, target)

df_ed_state <- read.csv(paste0(cdc_api,
                               "vutn-jzwm/rows.csv?&accessType=DOWNLOAD")) |>
  dplyr::filter(pathogen == "Influenza") |> 
  dplyr::mutate(location = location2number[geography],
                age_group = "0-130", target = "% ed visit") |>
  dplyr::select(location, date = week_end, observation = percent_visits,
                age_group, target)

df_ed <- rbind(df_ed_state, df_ed_demo)

# Store previous version in the Archive ----------------------------------------
old_files <- "target-data/time-series.csv"
arch_files <-
  gsub(".csv", paste0("_", Sys.Date(), ".csv"),
       paste0("auxiliary-data/", gsub("get-data", "get-data_archive",
                                      old_files)))
file.rename(old_files, arch_files)

# Write output -----------------------------------------------------------------
df_tot <- rbind(df_nhsn, df_ed)
write.csv(df_tot, "target-data/time-series.csv",
          row.names = FALSE)

# Clean environment ------------------------------------------------------------
rm(list = ls())
