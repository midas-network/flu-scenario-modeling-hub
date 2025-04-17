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
location2number <- setNames(model_location$location,
                            model_location$location_name)


# NHSN Hospitalization Data ----------------------------------------------------
df_nhsn <- extract_nhsn(hosp_report = TRUE, pathogen = "Influenza") |>
  standard_nhsn(location2number, abbr2location) |>
  dplyr::mutate(target = "inc hosp")

# Store previous version in the Archive ----------------------------------------
old_files <- "target-data/time-series.csv"
arch_files <-
  gsub(".csv", paste0("_", Sys.Date(), ".csv"),
       paste0("auxiliary-data/", gsub("get-data", "get-data_archive",
                                      old_files)))
file.rename(old_files, arch_files)

# Write output -----------------------------------------------------------------
write.csv(df_nhsn, "target-data/time-series.csv",
          row.names = FALSE)

# Clean environment ------------------------------------------------------------
rm(list = ls())
