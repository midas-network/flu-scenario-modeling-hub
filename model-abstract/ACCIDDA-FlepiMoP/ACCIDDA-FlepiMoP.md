# Summary of Results
We calibrated an age- and state-stratified SEIR model to weekly MMWR influenza hospitalization incidence data. Location-specific relative-humidity (RH) GAMs were used to set prior shape for r₀(t); and smooth, unit-mean weekly Fourier deviations were learned from data for each state. Initial immunity pR(age, state) was inferred and used to set S(0).  Vaccination flows and waning move individuals among unvaccinated → `1-dose` → `waned` with leaky protection. For legacy FluSurv-Net states, we used all available historical seasons excluding 2020–21 and 2021–22; for states without older coverage than HSHN, we used the three most recent seasons. The model reproduces observed hospitalizaion incidence well across all season x location combinations, with uncertainty driven mainly by seasonality deviations and pR.

# General Model Description
Age, vaccination status (`unvaccinated`, `1-dose`, `waned`), and location stratified deterministic SEIR model with a linear-chain infectious period (I1 → I2 → I3) to yield an Erlang infectious duration. 

# Explanation of observed dynamics given model assumptions
Model dynamics are primairly driven by the combination of the combination of the relative-humidity driven r₀ curve, the intial suseptible and recovered populations, and the weekly Fourier driven deviations.   

# Model Calibration
Weekly state-level hospitalizations are aligned to model MMWR weeks and fit with a simple Poisson likelihood. 
Per-state calibration parameters include Fourier coefficients for r₀ scaling, pR(age), a small age scaling of outcomes, and a location intercept.  We treated each location x season combination as an indpendent model calibration excercise.
# Model Assumptions
## Immunity assumptions
Leaky protection at susceptibility. Infection-derived immunity is carried in R; vaccination modifies susceptibility via
age-specific multipliers, with waning from 1-dose to waned.

### Number/type of immune classes considered
R (infection-derived). Vaccination strata: `unvaccinated`, `1-dose`, `waned` (different susceptibility multipliers).

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2025-26 season. 
`pR(age, state)` is inferred and determines `S(0)` by setting the S/R split within each age group.

### How is variability in this parameter engineered, if any?
Uncertainty in `pR` is sampled during calibration (per age, per state), propagating to credible intervals for `S(0)`, epidemic size, and peak timing.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2025-26 season.
Uncertainty in `pR` is sampled during calibration (per age, per state), propagating to credible intervals for `S(0)` thus inferring intial proporiton of the population with immunity regardless of source to start the season. All vaccine classes (`1-dose`, `unvaccinated`, `waned`) have their own `S` compartments, and the effect of that staus is on the probability of infection given contact.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
Yes `1-dose` wanes to `waned` during the season. Infection-derived immunity regardless of vaccine class is treated as durable over a single season (expected duration of protection ~8 months). 

## Details on Influenza Strain(s)
### Number of strains/subtypes included in model
One aggregate influenza strain; no subtype interactions modeled.

### Strain(s) specifications (immune escape, transmissibility)
Not parameterized beyond seasonality r₀(t) and age/vaccination susceptibility multipliers.

### Are interactions between strains/subtypes implicitly modeled?
No.

## Seasonality implementation
The prior r₀(t) curve is location-specific from a GAM fit to relative humidity. We then fit the unit-mean weekly Fourier deviations (6 harmonics) per state to capture local departures while keeping the annual mean fixed. A short winter holiday reduction is included.

## Initial Conditions
Base initial conditions are adjusted so that pR(age, state) sets the S/R split within each age band, fixing S(0) while preserving other stage and vaccination masses.

### Details on circulating strains at the start of the projection period
Single aggregate strain with low background importation for seeding.

## Non-pharmaceutical interventions (NPIs)
Only a winter-holiday contact reduction is represented; otherwise, no explicit NPIs are used in training seasons.

## Age Group Variability
### No of age groups
Five: 0–4, 5–17, 18–49, 50–64, 65+.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Age-specific leaky susceptibility multipliers by vaccination stage; vaccination time series are age-specific. 
waning applies uniformly from `1-dose` to `waned`.

## State-level Variability
### State-stratification details (prior immunity, vaccine coverage)
Per state, we infer pR(age) and seasonality deviations; vaccination uptake inputs are age- and state-specific. 
Training data vary by coverage (see Summary).

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
Represented by age- and stage-specific leaky susceptibility multipliers. Time-varying vaccination rates move
individuals into `1-dose`, with waning to `waned`.

### VE against mortality (by age, if relevant)
Not explicitly modeled; severity handled via age-specific hospitalization probabilities and a short delay.

### VE against transmission (by age, if relevant)
Not modeled (vaccine acts on susceptibility and hospitalization only).

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky.

### Summarize how uncertainty is generated within a single scenario. 
1. **Resampled parameters:** per-state Fourier seasonality coefficients, pR(age), minor age-scaling of outcomes, and a location intercept.  
2. **No process noise:** ODE dynamics are deterministic; uncertainty arises from parameter inference.

## Other Model Assumptions
- Erlang infectious period via a linear chain (I1 → I2 → I3).  
- Vaccination dynamics: time-varying, age-specific dose-1 uptake with waning to a reduced-protection class.  
- Hospitalization mapping: age-specific probabilities (and a short delay) calibrated to recent seasons.  
- Training data:  
  - Legacy FluSurv-Net states: all available seasons except 2020–21 and 2021–22.  
  - States without older coverage than HSHN: three most recent seasons.  

