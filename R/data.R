#' USRDS 2021 remaining life expectancy in people with ESRD
#'
#' A dataset compiled from the USRDS Annual Data Report (ADR) for 2021
#' containing the remaining life expectancy of people with ESRD.
#'
#' @format A tibble with 10 rows and 10 variables: \describe{
#'   \item{age_group}{Five-year age groups as reported by USRDS. The oldest age
#'   group is 85+.}
#'   \item{age_min}{Minimum age in each age group.}
#'   \item{age_max}{Maximum age in each age group.}
#'   \item{group_years}{Length of age groups.}
#'   \item{dialysis_female}{Remaining life expectancy in women with ESRD.}
#'   \item{dialysis_male}{Remaining life expectancy in men with ESRD.}
#'   \item{remaining_years}{Remaining life expectancy
#'   averaged across women and men with ESRD.}
#'   \item{data_year}{Year to which data pertains.}
#'   \item{data_source}{String for table in USRDS ADR from
#'   which data were sourced.}
#'   \item{data_url}{URL for chapter in USRDS ADR from
#'   which data were sourced.}
#'   }
#'
#' @source
#'   \url{"https://adr.usrds.org/2021/end-stage-renal-disease/6-mortality"}
#'
"usrds_esrd_mort_2019"
