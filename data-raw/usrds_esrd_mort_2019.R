#' Prepare ESRDS mortality data from 2021 Annual report
#'
#' Reads in raw .csv with USRDS data and pre-processes for use in app
#'
#' @return An .rda file
#' @export
#'
#' @noRD
raw <- readr::read_csv("data-raw/usrds_esrd_mort_2019.csv")

usrds_esrd_mort_2019 <- raw |>
  dplyr::mutate(group_years = 5) |>
  dplyr::mutate(data_year = "2019") |>
  dplyr::mutate(
    data_source =
      "USRDS ADR 2021, Chapter 6: Mortality, Table 6.1"
  ) |>
  dplyr::mutate(
    data_url =
      "https://adr.usrds.org/2021/end-stage-renal-disease/6-mortality"
  ) |>
  dplyr::mutate(remaining_years = (dialysis_male + dialysis_female) / 2) |>
  dplyr::mutate(
    age_min =
      as.numeric(stringr::str_extract(age_group, "^[0-9]{2,3}")),
    age_max =
      dplyr::case_when(
        stringr::str_detect(age_group, "\\+") ~ 150,
        TRUE ~ as.numeric(stringr::str_extract(
          age_group,
          "[0-9]{2,3}$"
        ))
      )
  ) |>
  dplyr::select(dplyr::all_of(c(
    "age_group", "age_min", "age_max",
    "group_years", "dialysis_female",
    "dialysis_male", "remaining_years", "data_year",
    "data_source", "data_url"
  )))

usethis::use_data(usrds_esrd_mort_2019, overwrite = TRUE)
