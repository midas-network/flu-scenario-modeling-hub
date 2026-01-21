# Standardize output in SMH format
cdc_nhsn_standardize <- function(raw, sel_col,
                                 pathogen = c("COVID", "Influenza", "RSV"),
                                 age_group = FALSE) {
  id_col <- c("Week.Ending.Date", "Week Ending Date", "Geographic aggregation",
              "Geographic.aggregation")
  df <- dplyr::select(raw, dplyr::any_of(c(sel_col, id_col)))
  df <- tidyr::pivot_longer(df, cols = dplyr::contains("Admissions"),
                            names_to = "disease", values_to = "observation")
  df <- dplyr::mutate(df,
                      pathogen = stringr::str_extract(.data[["disease"]],
                                                      paste(pathogen,
                                                            collapse = "|")))
  out_col <- c("pathogen", "observation")
  if (age_group) {
    df <- tidyr::separate(df, .data[["disease"]],
                          into = c("disease", "age_group"), sep = "\\.\\.|, ")
    df <- dplyr::mutate(
      df,
      age_group = gsub("plus", "130",
                       gsub("-$", "",
                            gsub("\\.\\ ", "-",
                                 gsub("years|age", "",
                                      gsub("\\+", "-130",
                                           .data[["age_group"]]))))) |>
        trimws()
    )
    out_col <- c(out_col, "age_group")
  }
  df <- dplyr::select(df, date = dplyr::matches("Week.Ending.Date"),
                      state_abbr = dplyr::matches("Geographic.aggregation"),
                      dplyr::all_of(out_col))
  return(df)
}

# Column selection
column_selection <- function(raw, pathogen = c("COVID", "Influenza", "RSV"),
                             hosp_report = TRUE, hosp_report_unit = "percent",
                             age_group = TRUE) {
  # Select Admissions data
  sel_col <- grep("(\\ |\\.)Admissions", colnames(raw), value = TRUE)
  sel_col <- grep("Change|100(.|,)000", sel_col, value = TRUE, invert = TRUE,
                  ignore.case = TRUE)
  sel_col <- grep("Cumulative", sel_col, value = TRUE, invert = TRUE,
                  ignore.case = TRUE)
  # Select only pathogen of interest
  sel_col <- grep(paste(pathogen, collapse = "|"), sel_col, value = TRUE,
                  ignore.case = TRUE)
  # Keep or not reporting information
  sel_col_report <- NULL
  if (hosp_report) {
    sel_col_report <- grep("reporting", sel_col, value = TRUE,
                           ignore.case = TRUE)
    sel_col_report <- grep(hosp_report_unit, sel_col_report, value = TRUE,
                           ignore.case = TRUE)
    sel_col_report <- grep("pediatric|adult|(A|a)bove", sel_col_report,
                           value = TRUE, ignore.case = TRUE, invert = TRUE)
  }

  sel_col <- grep("reporting", sel_col, value = TRUE, ignore.case = TRUE,
                  invert = TRUE)
  # Keep or not demographic data
  sel_col_demo <- NULL
  if (age_group)
    sel_col_demo <- grep("year|age|75(\\.|\\ )?(plus|+)", sel_col, value = TRUE,
                         ignore.case = TRUE)
  sel_col <- grep("year|age|75(.plus|+)?", sel_col, value = TRUE,
                  ignore.case = TRUE, invert = TRUE)
  # Remove percent data & (adult, pediatric) data
  sel_col <- grep("percent|pediatric|adult", sel_col, value = TRUE,
                  ignore.case = TRUE, invert = TRUE)
  # Output list of selection columns
  col_list <- list(sel_col = sel_col, sel_col_demo = sel_col_demo,
                   sel_col_report = sel_col_report)
  return(col_list)
}

#' Extract data from Weekly Hospital Respiratory Data (HRD) Metrics by
#' Jurisdiction, National Healthcare Safety Network (NHSN)
#'
#' Extract data from NHSN and standardized in SMH format.
#'
#' @param cdc_data_ref CDC reference of the data, by default "ua7e-t2fy"
#' @param pathogen Pathogen to extract, by default all pathogen selected:
#'   "COVID" (for COVID-19 data), "Influenza" and "RSV"
#' @param hosp_report Boolean, if TRUE returns percent/number of hospitals
#'   reporting new admissions of patients of the reporting week
#' @param hosp_report_unit Character string, unit of hospitals reporting:
#'   "percent" (default) or "number"
#' @param age_group Boolean, if TRUE (default) include age group information
#'
#' @details
#' ## Source:
#' Weekly Hospital Respiratory Data (HRD) Metrics by
#' Jurisdiction, National Healthcare Safety Network (NHSN):
#' [data.cdc.gov](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/)
#'
#' ## Column Selection
#'
#' - Observation extracted from: `"Total [PATHOGEN] Admissions"`
#' - Age group information from:
#'   `"Number of Adult [PATHOGEN] Admissions, [AGE GROUP] years"`
#' - Hospital reporting from:
#'   `"[Number|Percent] Hospitals Reporting RSV Admissions"`
#'
#' @export
extract_nhsn <- function(cdc_data_ref = "ua7e-t2fy",
                         pathogen = c("COVID", "Influenza", "RSV"),
                         hosp_report = TRUE, hosp_report_unit = "percent",
                         age_group = TRUE) {
  # Load data
  down_link <- paste0("https://data.cdc.gov/api/views/", cdc_data_ref,
                      "/rows.csv?&accessType=DOWNLOAD")
  raw <- read.csv(down_link, check.names = FALSE)

  # Column selection
  list_col <- column_selection(raw, pathogen = pathogen, age_group = age_group,
                               hosp_report = hosp_report)

  # Filter and standardize data
  df <- cdc_nhsn_standardize(raw, list_col$sel_col)
  if (!is.null(list_col$sel_col_demo)) {
    df_demo <- cdc_nhsn_standardize(raw, list_col$sel_col_demo,
                                    pathogen = pathogen, age_group = TRUE)
    df$age_group <- "0-130"
    df <- rbind(df, df_demo)
  }
  if (!is.null(list_col$sel_col_report)) {
    df_report <- cdc_nhsn_standardize(raw, list_col$sel_col_report,
                                      pathogen = pathogen)
    df_report <- dplyr::rename(df_report,
                               report = dplyr::matches("observation"))
    if (!is.null(list_col$sel_col_demo))
      df_report$age_group <- "0-130"
    df <- dplyr::left_join(df, df_report)
  }
  # Output
  return(df)
}

#' Standardize data output from NHSN into US SMH/hubverse format
#'
#' @param df_us data frame containing NHSN data (for one specific pathogen)
#' @param location2number named character vectors used as an hash table to
#'  translate location name to location FIPS
#' @param abbr2location named character vectors used as an hash table to
#'  translate location abbreviation 2 character code to location name
#' @param report_limit double, remove data point with an associated
#'  hospital report percent under the `report_limit` value for all associated
#'  location
standard_nhsn <- function(df, location2number, abbr2location,
                          report_limit = 0.75) {
  df <- dplyr::mutate(df,
                      report = ifelse(is.na(.data[["report"]]),
                                      unique(na.omit(.data[["report"]])),
                                      .data[["report"]]),
                      .by = c("date", "state_abbr", "pathogen"))
  if (!is.null(report_limit)) {
    df <-
      dplyr::mutate(df, observation = ifelse(.data[["report"]] < report_limit &
                                               !is.na(.data[["report"]]),
                                             NA, .data[["observation"]]))
  }
  df <-
    dplyr::filter(df, !grepl("Region \\d+", .data[["state_abbr"]])) |>
    dplyr::mutate(date = as.Date(date),
                  location =
                    location2number[abbr2location[.data[["state_abbr"]]]],
                  age_cat =
                    dplyr::case_when(.data[["age_group"]] == "0-4" ~ "0-4",
                                     .data[["age_group"]] == "5-17" ~ "5-17",
                                     .data[["age_group"]] == "18-49" ~ "18-49",
                                     .data[["age_group"]] == "50-64" ~ "50-64",
                                     .data[["age_group"]] %in%
                                       c("65-74", "75-130") ~ "65-130",
                                     .data[["age_group"]] %in% "0-130" ~
                                       "0-130",
                                     .data[["age_group"]] == "unknown" ~ NA)) |>
    dplyr::summarise(observation = sum(.data[["observation"]]),
                     .by = c("date", "location", "age_cat")) |>
    dplyr::filter(!is.na(.data[["age_cat"]]), !is.na(.data[["observation"]])) |>
    dplyr::select(tidyr::all_of(c("date", "location", "observation")),
                  age_group = tidyr::all_of("age_cat"))
}
