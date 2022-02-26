#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      titlePanel("slopeR: Calculate Time to Dialysis and Associated Costs"),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Time points"),
          mod_time_points_ui("time_points_ui_1"),
          h4("Treatments"),
          splitLayout(
            mod_tx_ui("tx_ui_1", tx_value = "Tx 1"),
            mod_tx_ui("tx_ui_2", tx_value = "Tx 2")
          ),
          h4("Population"),
          mod_egfr_data_ui("egfr_data_ui_1"),
          numericInput("base_age",
            "Baseline age (years)",
            value = 60,
            min = 0,
            max = 120,
            step = 1
          ),
          h4("Costs"),
          splitLayout(
            textInput("currency",
              "Currency",
              value = "USD"
            ),
            numericInput("dial_cost",
              "Annual dialysis cost",
              value = 50000,
              min = 0,
              step = 100
            ),
            numericInput("disc_rate_perc",
              "Annual discount rate (%)",
              value = 3.5,
              min = 0,
              max = 100,
              step = 0.01
            )
          )
        ),
        mainPanel(
          h2("Time to dialysis (TTD, years) and discounted dialysis costs"),
          mod_results_table_ui("results_table_ui_1"),
          h2("eGFR over time"),
          mod_egfr_plot_ui("egfr_plot_ui_1"),
          h2("Methods and sources"),
          p(
            HTML(
              "<ul>
               <li>This calculator is based on a 2021 paper by Michael Durkin
                    and Jaime Blais, on eGFR decline with canagliflozin
                    (<a href='https://pubmed.ncbi.nlm.nih.gov/33340064/'
                    target='_blank'>Diabetes Ther, 2021, 12(2):4-99-508</a>).
              </li>
              <li>Time spent on  dialysis is the time between initiation of
                    dialysis and death, assuming no competing risks. Expected
                    remaining life-years of patients with
                    ESRD on dialysis come from
                    <a href='https://adr.usrds.org/2021/end-stage-renal-disease/6-mortality'
                    target='_blank'>2021 USRDS Annual Data Report, ESRD
                    Volume, Ch. 6</a> and are from 2019. Data were averaged,
                    by age group, across sex.
              </li>
              <li>Dialysis costs are the product of annual dialysis cost and
                  number of years on dialysis, divided by
                  the discount factor raised to the power of years to treatment initiation.
              </li>
              </ul>"
            )
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www")
  )

  tags$head(
    favicon(ext = "png"),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "sloper"
    ),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "www/custom.css"
    )
  )
}
