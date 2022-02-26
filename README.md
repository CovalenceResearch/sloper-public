
<!-- README.md is generated from README.Rmd. Please edit that file -->

# slopeR

*slopeR* is a [Shiny app](http://cloud.covalence-research.com/sloper/)
designed to calculate time to dialysis and associated costs from
estimated glomerular filtration rates (eGFR), for up to two treatments.
The calculation is based on a 2021 article by [Durkin and
Blais](https://pubmed.ncbi.nlm.nih.gov/33340064/). Please note that this
Shiny app is implemented independently of these authors and all errors
in this app, which comes without any warranty, are our own.

# How it works

The model developed by Durkin and Blais, which was implemented in this
Shiny app, calculates eGFR trajectories using the acute and chronic
slope from a cohort baseline eGFR value. Within the acute and chronic
phase, respectively, eGFR is assumed to change linearly.

eGFR trajectories are calculated until they reach the user-specified
eGFR threshold for dialysis initiation. The time it takes for eGFR to
reach this threshold is combined with a user-specified cohort baseline
age to calculate, for each treatment, the age at dialysis initiation.

This age is then used to find the corresponding estimate for remaining
life expectancy in patients with end-stage renal disease (ESRD). These
estimates came from the 2021 United States Renal Data Service Annual
Data Report, [Chapter 6:
Mortality](https://adr.usrds.org/2021/end-stage-renal-disease/6-mortality).
For their remaining lifetime, patients are assumed to remain on dialysis
so their remaining life time is the time to dialysis (TTD).

Costs are then calculated, for each treatment and eGFR slope, by
multiplying TTD with annual costs of dialysis. These costs can then be
compared across treatments and give an estimate of what total costs and
cost savings would be with each treatment, based on its impact on eGFR.

# How to use

## Inputs

For using *slopeR*, you should have **acute** and **chronic** eGFR
slopes, i.e., changes in eGFR between two time points. Such data are
publicly available from clinical trials, but of course you can just
explore assumptions for a treatment. Note that all eGFR values in
*slopeR* are in the ‘standard’ eGFR unit: mL/min/1.73m<sup>2</sup>.

In *slopeR*, you must specify the **length of the acute phase** and
**trial end**, both in weeks. During the acute phase, the **acute eGFR
slope** applies, between the end of the acute phase and the trial end,
the **chronic eGFR slope** applies. In addition, you can explore lower
and higher values than the main estimate. These work exactly the same
way as the main estimate but save you some time by allowing you to
investigate three values at once for a specific treatment. You can also
specify names for each treatment to have table and figure outputs
labelled specifically to your case.

You must also specify two population parameters for the cohort you’re
interested in: the baseline **age** and the baseline **eGFR value**. You
also need to specify at which eGFR threshold **dialysis** is initiated.

Finally, you must specify the **annual dialysis cost** and the **annual
discount rate**. You can also specify the **currency label** for
labelling table columns (no currency conversion of any kind is
performed).

## Outputs

The calculation returns two outputs in the Shiny app:

-   A **table**, which contains, for each treatment and slope
    (combinations of treatment and slope each form a row): – Time to
    dialysis (TTD) in years and the difference in TTD between treatments
    – Age at dialysis initiation – Time on dialysis – Costs and
    incremental costs for dialysis
-   A **figure**, which shows eGFR trajectories for each treatment and
    user-specified eGFR value until the dialysis intiation threshold is
    reached.
