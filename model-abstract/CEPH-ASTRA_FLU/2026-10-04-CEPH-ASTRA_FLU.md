# General Model Description
ASTRA_FLU is a computational modeling framework built around an age-structured compartmental model that simulates the
co-circulation of three influenza types/subtypes, A(H1N1), A(H3N2), and B, accounting for cross-protection between them
and the effects of vaccination. The framework calibrates the transmission model independently for each US state and the
District of Columbia using hospitalization data from the last four influenza seasons. For the 2026–27 projections, 
parameter sets that reproduce the observed epidemics in these four seasons are sampled and used to rerun the model under
the specified vaccination scenarios, estimating influenza hospitalizations and the impact of vaccination.

# Summary of Results
Nationally, we project 256,002 (95% PI: 211,422-461,068) cumulative influenza hospitalizations between October 4, 2026,
and June 5, 2027, under scenario B, with a median weekly peak of 26,956 (18,244-46,962) admissions in the week ending 
January 9, 2027 (95% PI: December 12, 2026 - February 13, 2027). Compared with no vaccination (scenario D), scenario B
reduces hospitalizations by 50.3% (44.7-56.2%), while scenario A reduces hospitalizations by 62.1% (55.5-69.4%). 
Approximately 60% of hospitalizations averted under scenario B occur among adults aged 65 years and older, for whom 
vaccination reduces hospitalizations by 58.0% (53.8-63.9%). 

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
The model is calibrated to weekly influenza hospital admissions by state from the NHSN Weekly Hospital Respiratory Data
for the 2022-23, 2023-24, 2024-25, and 2025-26 seasons, between epiweek 40 and epiweek 21. State totals are 
disaggregated by age (0-4, 5-17, 18-49, 50-64, 65+) using the population-weighted age distribution of hospitalizations
from RESP-NET (FluSurv-NET), and by type/subtype using the national weekly proportions of A(H1N1), A(H3N2), and B among
positive specimens from public health laboratories (WHO/NREVSS, FluView). For each state and season, a strain-specific 
reproduction number and introduction date are estimated using a two-step process. First, a differential evolution 
algorithm attempts to find the global optimum for the parameters that minimize the root-mean-square error between 
modeled and observed weekly age-specific hospitalizations of the three strains fitted jointly.  Then, from that optimum,
we explore the parameter space with an affine-invariant MCMC ensemble sampler that estimates the posterior distribution 
of the model parameters. The final curves are randomly sampled from the distribution given by the affine-invariant MCMC. 
Vaccination during the calibration seasons follows the observed coverage curves provided in previous SMH rounds.

# Model Assumptions
## Immunity assumptions
Infection with a given strain provides complete immunity against reinfection with the same strain for the rest of the 
season, and partial protection against infection with the other strains: 40% between A(H1N1) and A(H3N2), and 20% 
between either influenza A subtype and B. Protection from several prior infections within the season combines 
multiplicatively. Vaccination provides leaky protection against infection (25%) and against hospitalization given 
infection (50%).

### Number/type of immune classes considered
Each individual is classified by infection history (8 classes: never infected, or previously infected with any 
combination of H1N1, H3N2 and B during the season) and by vaccination status (unvaccinated or vaccinated), in each 
single year of age. 

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
Pre-existing immunity from previous infections and vaccinations is not explicitly modeled. Instead, all individuals are 
assumed to have the same level of residual protection, which is implicitly incorporated into the strain-specific 
effective reproduction numbers (Reff) estimated during calibration. Thus, although the entire population is initialized
in the susceptible compartment (S0 = 1), this does not imply that individuals are fully susceptible to infection. 
Indeed, the calibrated reproduction numbers are effective reproduction numbers rather than basic reproduction numbers.

### How is variability in this parameter engineered, if any?
N/A

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
0% (S0 = 1 in all age groups); see above.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
No.

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
Yes. A(H1N1), A(H3N2) and B are modeled as distinct co-circulating strains.

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
Each strain has its own transmission rate, introduction date and age-specific infection-to-hospitalization ratios, all 
calibrated by state and season

### Are interactions between strains/subtypes/pathogens implicitly modeled?
They are modeled explicitly: infection with one strain reduces susceptibility to the other strains for the rest of the 
season, by 40% between A(H1N1) and A(H3N2) and by 20% between either A subtype and B.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
Not explicitly modeled

## Initial Conditions
Simulations start in late July of each season (July 25, 2026, for the projections), with the whole population 
susceptible and unvaccinated. Individuals are vaccinated during the season and a date of introduction is estimate for 
each circulating strain.

### Details on circulating strains at the start of the projection period or on how strains are introduced
No influenza strains are circulating at the start of the simulations. Each strain is introduced by seeding a small 
number of latent infections on a strain-specific date estimated during calibration. For the 2026-27 projections, 
introduction dates are obtained from the parameter sets sampled from the four historical seasons.

### Details on pre-existing immunity (if applicable)
N/A

## Non-pharmaceutical interventions (NPIs)
None.

## Age Group Variability
### No of age groups
100 single-year age groups (0-99+).

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Age-specific contact patterns and age-specific infection-to-hospitalization ratios. Susceptibility to infection and 
vaccine effectiveness are assumed to be the same across ages.

## State-level Variability
### Describe the spatial structure of the model, if any
Each of the 50 states and the District of Columbia is modeled and calibrated independently, with state-specific 
population age structure, contact matrix and vaccination coverage. There is no coupling between states. National 
projections are obtained by aggregating state-level trajectories.

### Provide state-stratification details on calibrated parameters and initial conditions (eg, prior immunity, R0)
Strain-specific effective reproduction numbers (Reff), introduction dates, and age-specific infection-to-hospitalization
ratios are calibrated independently for each state and season. State-specific population age structures, contact 
matrices, and vaccination coverage are used. Initial conditions are otherwise the same across states, with the entire 
population initialized in the susceptible compartment (S0 = 1) and no circulating infections.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
25% for all ages and strains

### VE against hospitalization given infection (by age, if relevant)
50% for all ages and strains

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
None

### VE against mortality (if any effect beyond VE against infection and hospitalization)
N/A; the model does not consider mortality.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky: vaccinated individuals are infected at a rate reduced by 25%, and those infected are hospitalized at a rate 
reduced by 50%.

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
Vaccine protection and the cross-protection from other strains combine multiplicatively.

## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
1. Yes. For each state, parameter sets are sampled from those obtained during calibration to the four historical 
influenza seasons. These include strain-specific effective reproduction numbers, introduction dates, and the 
corresponding age- and strain-specific infection-to-hospitalization ratios. This approach captures both parameter 
uncertainty and variability across seasons and states.
2. No

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
The framework has been extended to explicitly model the co-circulation of multiple influenza strains. In addition, the 
calibration procedure has been completely revised, including the estimation of the posterior distributions of model 
parameters.

## Other Model Assumptions
Strain-specific hospitalization curves are obtained by applying national strain proportions among laboratory-positive 
specimens uniformly to hospitalizations in all states and age groups.
