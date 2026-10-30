# General Model Description
We simulate influenza transmission in each of the 51 US jurisdictions with a deterministic SEIR model stratified by five age groups (0 to 4, 5 to 17, 18 to 49, 50 to 64, 65 and over) and three vaccination stages (unvaccinated, vaccinated, waned), with an Erlang-3 infectious period (I1 to I2 to I3), age-assortative mixing from synthetic contact matrices, and a cumulative-incidence compartment from which weekly hospital admissions are read at MMWR week boundaries. The model runs in flepiMoP (the `flepimop2` pipeline with the `op_system` model specification and the `op_engine` solvers), with a fixed-step fourth-order Runge-Kutta scheme at half-day steps. The 51 jurisdictions are simulated as independent systems that share parameters through a hierarchy over five seasons (2022-23 to 2026-27) and over states, so that the 2026-27 season is informed by the four seasons before it as well as by its own first weeks.

Transmission in state s and season y is r0(t) = r0_baseline,s(t) exp(level_{s,y} + F_y(t)), where r0_baseline,s(t) is a location-specific climatological seasonal curve derived from absolute humidity and F_y(t) is a two-harmonic Fourier deviation whose coefficients are shared across states and allowed a season-specific departure. The level is parametrized through the season maximum of the effective reproduction number without depletion, log Re*_{s,y} = mu + a_y + b_s + e_{s,y}, so that the prior on transmissibility is stated in terms of Re rather than of r0. Infections are seeded by a small external force of infection that is switched off on 1 February. Hospital admissions are the product of infections, age-specific per-infection hospitalization probabilities with estimated age multipliers, and a state reporting factor with a season shift, delayed three days from the onset of infectiousness; weekly counts by age are observed with negative-binomial noise and a shared dispersion.

# Summary of Results
Under scenario B (usual vaccine coverage) the model projects [[333,000]] influenza hospital admissions in the United States between 4 October 2026 and 5 June 2027 (90% interval [[117,000 to 875,000]]; about [[98]] per 100,000), with about 60% of admissions in people aged 65 and over. Individual trajectories peak at a median of [[27,000]] weekly admissions (90% interval [[9,000 to 96,000]]) in a median week ending [[6 February 2027]] (10th to 90th percentile [[28 November to 24 April]]); the median trajectory itself peaks earlier and lower, near [[12,000]] in the week ending [[5 December]], because early and late peaks are averaged. The early 2026-27 season (national admissions rising from about 1,000 in late August to about 5,000 by mid October) is reproduced by the calibrated runs, and the first week after the fitting window fell within the central 90% of the predictive distribution nationally and in [[47 of 51]] jurisdictions. Relative to the no-vaccination counterfactual (D), the model indicates that vaccination averts a median [[16.5%]] of hospitalizations under usual coverage (B; 90% interval [[8 to 30%]]), [[21%]] under optimistic coverage (A; [[10 to 37%]]) and [[14%]] when only adults are vaccinated (C; [[8 to 21%]]); childhood vaccination (B against C) averts a median [[3.2%]] ([[0.2 to 11%]]). The all-age susceptible proportion on 4 October (S0) has median [[0.54]] (90% interval [[0.36 to 0.76]]) across trajectories. The upper tail of the projections is long, as it was in our earlier submissions, because the historical seasons admit large late peaks that the first weeks of a season do not rule out.

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
We calibrated to weekly influenza hospital admissions from NHSN as distributed in the hub's target data, using the all-age series for 2022-23 and 2023-24 and the age-specific series for 2024-25, 2025-26 and 2026-27; the 2026-27 window ends on [[3 October 2026]]. Age-specific hospitalization probabilities, the humidity-derived seasonal curve and the vaccination histories are those of our 2025-26 model.

Calibration has two steps. First, we fit the hierarchical model over all seasons and states by amortized neural posterior estimation: a bank of 100,000 simulations of the population-level parameters and a bank of 3,000,000 simulations of the state-level parameters were drawn from the prior, masked autoregressive flows (five random seeds each) were trained on them, the five networks were combined as a mixture, and the posterior was read from the observed data. Simulation-based calibration on 1,000 replicates checked that the posterior widths and coverage match the prior-predictive truth before any real-data fit was read. Second, because the amortized posterior for the 2026-27 season terms was close to its prior while the observed season was earlier and steeper than any of the training seasons, we re-estimated the 2026-27 cell of each retained posterior draw against the exact likelihood: holding the 2022-23 to 2025-26 parameters at the draw, we maximized the negative-binomial log likelihood of the observed 2026-27 weeks plus a Gaussian penalty centred on the draw with the posterior's marginal standard deviations, jointly over the seven season-level terms (level, four Fourier coefficients, immunity shift, reporting shift) and the four 2026-27 terms of each state (seed, initial exposed, level and immunity departures), and drew the spread from a Laplace approximation with importance resampling. This is a cut model in the sense of Plummer (2015): the current season is updated by its data, the historical seasons are not. The result was validated against hub and NHSN weeks after the fitting window before it was adopted (see Summary of Results); the pre-registered acceptance rules and their outcomes are recorded in our repository's decision log.

# Model Assumptions
## Immunity assumptions
Protection is leaky and acts on susceptibility and on the probability of hospitalization given infection. Infection-derived immunity is carried in the recovered compartment and is treated as durable within a season; immunity carried over from earlier seasons enters through the initial immune fraction q (below), which is estimated per state, season and age.

### Number/type of immune classes considered
One recovered class for infection-derived immunity, and three vaccination stages (unvaccinated, vaccinated, waned) with stage-specific susceptibility and hospitalization multipliers.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
The initial immune fraction by age is q_{s,y,a} = logistic(logit(m_a) + mu_q + beta_a + eta_y + u_s + d_{a,s} + w_{s,y}), with age means m_a of (0.15, 0.38, 0.27, 0.30, 0.30) for the five age groups taken from the literature on pre-season susceptibility, a national mean shift mu_q, a national age deviation beta_a, a season shift eta_y, a state shift u_s, a state-by-age term d_{a,s} and a state-by-season term w_{s,y}. The 2026-27 values of eta and w are among the terms re-estimated against the current season's data, so the pre-season immunity of 2026-27 is informed by its first weeks.

### How is variability in this parameter engineered, if any?
Every term of q is a parameter with a prior (mu_q N(0, 0.1^2), beta_a N(0, 0.3^2) summing to zero over ages, eta_y N(0, 0.4^2), u_s N(0, 0.3^2), d_{a,s} N(0, 0.3^2), w_{s,y} a Student t with four degrees of freedom and a half-normal scale) and is sampled in the posterior, so the variability of S0 across trajectories is the posterior variability of q given five seasons of admissions.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
Yes for vaccination: the vaccinated stage moves to the waned stage at a constant rate, and the waned stage retains a share of the vaccinated stage's protection. The rate and the share are drawn per trajectory from a distribution fitted to published estimates of within-season VE decline (median decline 8.5 percentage points per month; late-season VE a Beta(1, 3) share of the peak), the same draw in every state and scenario. Infection-derived immunity does not wane within the season.

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
No. One aggregate influenza type is modelled.

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
Not applicable. Antigenic change and subtype dominance are not represented explicitly; their effect on a season enters through the season-level terms (a_y, f_y, eta_y), which are estimated for each season and, for 2026-27, from the season's first weeks.

### Are interactions between strains/subtypes/pathogens implicitly modeled?
No.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
The baseline r0(t) of each state is a climatological curve derived from a generalized additive model of absolute humidity, with the 2025 series repeated by day of year to cover 2026-27; the fitted two-harmonic Fourier deviation (coefficients shared across states, with a season-specific departure) adjusts the timing and shape of the season. External seeding stops on 1 February. No behavioural or holiday term is included in this round.

## Initial Conditions
Initial compartments are set from the initial-condition fractions of our 2025-26 model, with the susceptible and recovered masses within each age group and vaccination stage rescaled so that the recovered fraction equals q_{s,y,a}; the initial exposed mass is scaled by an estimated per-state term. The model window starts in early August so that the first observed weeks of the season are produced by the dynamics rather than imposed.

### Details on circulating strains at the start of the projection period or on how strains are introduced
A single aggregate type with a small external force of infection, scaled per state and season by an estimated seeding term and switched off on 1 February.

### Details on pre-existing immunity (if applicable)
See the immunity section; q_{s,y,a} is estimated and sets the susceptible fraction by age and state on 4 October (the S0 target).

## Non-pharmaceutical interventions (NPIs)
None.

## Age Group Variability
### No of age groups
Five: 0 to 4, 5 to 17, 18 to 49, 50 to 64, 65 and over.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Mixing between age groups follows state-specific synthetic contact matrices (Prem et al. 2021, urban and rural blended by the state's urban population share) aggregated to the five groups, with transmissibility calibrated so that the nominal R0 is the spectral radius of the next-generation matrix. Initial immunity, hospitalization probability (with estimated age multipliers whose logs sum to zero) and vaccination uptake are age-specific; VE and its waning are the same across ages.

## State-level Variability
### Describe the spatial structure of the model, if any
Each jurisdiction is simulated as a closed system with its own population by age, contact matrix, climatological r0 curve and vaccination history; there is no movement between jurisdictions.

### Provide state-stratification details on calibrated parameters and initial conditions (eg, prior immunity, R0)
Per state we estimate a persistent level departure b_s, a per-season level departure e_{s,y}, a persistent immunity shift u_s, age-specific immunity departures d_{a,s}, a per-season immunity departure w_{s,y}, a reporting factor rho_s, and per-season seeding and initial-exposed terms. Arkansas and Kansas have no age-specific hospital data in the fitting window and are projected from the prior conditional on the shared parameters.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
VE against infection for the vaccinated stage is drawn per trajectory from a Beta(5, 15) prior (mean 0.25, 90% interval about 0.11 to 0.42), the same in every age group.

### VE against hospitalization given infection (by age, if relevant)
The conditional protection against hospitalization given infection is set so that the total VE against hospitalization of the vaccinated stage is the hub's 50% in every age group, that is 1 - 0.5 / (1 - VE_inf) for the trajectory's VE_inf.

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
None beyond the reduction of infection.

### VE against mortality (if any effect beyond VE against infection and hospitalization)
Not modelled; deaths are not submitted in this round.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky.

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
Vaccine protection is independent of prior infection: the susceptibility multiplier applies to the susceptible fraction of each stage, and vaccination moves individuals between stages without changing their infection history.

## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
1. Each of the 495 trajectories is one paired draw from the posterior of all parameters listed above (natural history, level, Fourier shape, initial immunity, severity multipliers, reporting, seeding and initial exposed, by season and state), re-estimated for 2026-27 as described under calibration, together with its draw of VE against infection and of the waning parameters. The same draw is used across the four scenarios, so scenario contrasts are paired.
2. The dynamics are deterministic. Negative-binomial observation noise is added to the weekly counts by age with common random numbers across scenarios, so that the submitted samples carry the observation uncertainty of the fitted channel as well as the parameter uncertainty.

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
Compared with our 2025-26 submission: the seasons and states are fitted jointly in one hierarchical model rather than as independent location-by-season fits; the transmissibility prior is stated on the season maximum of Re; age mixing follows synthetic contact matrices rather than homogeneous mixing; the incubation period, infectious period, hospitalization delay and the age pattern of severity are estimated with literature priors; initial immunity is estimated per state, season and age; vaccine waning follows a fitted distribution rather than a fixed halving; the observation model is negative binomial rather than Poisson; and inference is amortized neural posterior estimation with simulation-based calibration, followed, in this round, by an exact-likelihood update of the current season.

## Other Model Assumptions
The incubation period (1 / sigma) has a lognormal prior with median 1.5 days and the infectious period (1 / gamma) median 4.0 days, both shared across states and seasons. Per-infection hospitalization probabilities by age are those of our earlier model with estimated age multipliers (log N(0, 0.4^2), summing to zero). Populations by age are the ACS state tables. Vaccination uptake by age and state follows the hub's coverage curves for each scenario. The projected trajectories do not account for antigenic change beyond what the season's first weeks reveal, for behavioural change, or for movement between jurisdictions, and the 2026-27 update is conditional on the historical-season parameters rather than a joint refit, so uncertainty about those parameters is propagated but not revised by the current season's data.
