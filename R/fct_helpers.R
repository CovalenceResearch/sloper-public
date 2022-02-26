#' Numeric input for eGFR slopes 
#'
#' @description A function to take numeric values for eGFR slopes.
#'
#' @return UI element
#'
#' @noRd
numericInputSlope <- function(id, label = NULL) {
  numericInput(id,
               label = label,
               min = -20,
               max = 20,
               value = -2,
               step = 0.01,
               width = "100%")
}
#' Numeric input for absolute eGFR values
#' 
#' @description  A function to take numeric values for eGFR.
#' 
#' @return UI element
#' 
#' @noRd
numericInputEGFR <- function(id, label = NULL, value = value, width = width) {
  numericInput(id,
               label = label,
               min = 0,
               max = 130,
               value = value,
               step = 1,
               width = width)
}
#' Text input for treatment labels
#' 
#' @description A function to take treatment label inputs.
#' 
#' @return UI element
#' 
#' @noRd
textInputTx <- function(id, label = NULL, tx_value = "Treatment x") {
  textInput(id,
            label = label,
            value = tx_value,
            width = "100%")
}
#' Cost calculation
#'
#' @description A function to calculate discounted costs (see Durkin 2021).
#'
#' @return Numeric value.
#'
#' @noRd
calculate_cost <- function(dial_cost,
                           discount_factor,
                           years_to_initiation,
                           years_of_tx) {
  cost <- dial_cost * years_of_tx / ((1 + discount_factor)^years_to_initiation)
}