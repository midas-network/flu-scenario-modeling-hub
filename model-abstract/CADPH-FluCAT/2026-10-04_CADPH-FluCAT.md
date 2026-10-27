# General Model Description
This model provides scenarios for the state of California only. The model is a stochastic, mechanistic model implemented via the tau-leap method with the following state variables:

- Susceptible = $S(t)$
- Vaccinated = $V(t)$
- Exposed: Unvaccinated = $E(t)$
- Exposed: Vaccinated = $E_v(t)$
- Infected: Unvaccinated = $I(t)$
- Infected: Vaccinated = $I_v(t)$
- Hospitalized = $H(t)$
- Dead = $D(t)$
- Recovered = $R(t)$

Scenario results are based on a sample size of 300 simulations per scenario, with four scenarios representing different flu vaccination coverage regimes (optimistic/pre-COVID-19, usual, usual-adults-only/no-pediatric, and a no-vaccination counterfactual).

# Summary of Results
For the 50% quantiles, all scenarios project a comparatively early peak in hospitalizations for the week of December 18, 2026. Projected median peak values for all scenarios are as follows:

- ~4,000 weekly admissions for no vaccination
- ~3,300 weekly admissions for usual vaccination for adults, no vaccination for children
- ~2,600 weekly admissions for usual vaccination
- ~2,100 weekly admissions for optimal vaccination

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
The model was calibrated using historical California Department of Health Care Access and Information (HCAI)/OSHPD hospital admissions and census data (2013-14 through 2020-21 seasons) and NHSN-imputed hospitalization data (2022-23 season through the current 2026-27 season), disaggregated by age class. CDC FluView/FluSurv-NET hospitalization rates were used as an initial starting point for age-specific hospitalization probabilities. Although in prior iterations of the model HCAI county-level death was data used to inform age-specific mortality-given-hospitalization probabilities, these values were modified to be able to calibrate to the estimated deaths for California for this round (https://github.com/midas-network/flu-scenario-modeling-hub_resources/blob/main/Rd7_datasets/CA_flu_deaths_adjusted_cumulative_long.csv)

Calibration was performed by applying age-specific multiplicative adjustment factors to baseline hospitalization and death probabilities such that `usual` scenarios reasonably replicated the shape and magnitude of historical multi-season CA hospitalization curves (see *Initial Conditions* below for further seeding-related calibration). Additionally, the timing and shape of the early-season transmission-rate ramp and infection-seeding schedule were tuned by comparing simulated early-season weekly incident hospitalizations against real-time NHSN data for the current 2026-27 season.

# Model Assumptions
## Immunity assumptions
Individuals can gain immunity via either prior infection, $R(t)$, or vaccination during the current season, $V(t)$. These are modeled as separate, mutually exclusive compartments.

### Number/type of immune classes considered
Individuals can be either Recovered, $R(t)$ (immunity due to prior infection), or Vaccinated, $V(t)$ (from vaccination during the current season). This model does not track immunity status resulting from different flu types or sub-types.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
Initial proportions with residual immunity were calculated as a function of the age-class population and the frequency with which different age classes experience flu infection (captured by the $\kappa$ values described in "Waning immunity" below). These values were calculated by solving a series of linear equations:

$0.054R_1+ 0.167R_2+ 0.442R_3+0.185R_4+0.153R_5= R(t=0)$ where the coefficients correspond to the relative proportion of the population in each age class, $R_i$ corresponds to the initial proportion of that age class that is immune, and $R(t=0)=0.30$ or $0.35$ depending on scenario bound. $R_i$ is then proportional to the rate of natural immunity waning for age class $i$, $\kappa_i$, such that, e.g., $r= \kappa_2/\kappa_1$ and $R_2 = rR_1$.

### How is variability in this parameter engineered, if any?
For each age class, prior immune status is drawn from a uniform distribution, with minimum and maximum bounds defined by the lower and higher overall prior-immunity scenarios below:

**Lower Overall Prior Immunity (overall 30%):**

- Ages 0-4: $R_1(t=0) = 0.0966$
- Ages 5-17: $R_2(t=0) = 0.1087$
- Ages 18-49: $R_3(t=0) = 0.2173$
- Ages 50-64: $R_4(t=0) = 0.4967$
- Ages 65+: $R_5(t=0) = 0.5796$

**Higher Overall Prior Immunity (overall 35%):**

- Ages 0-4: $R_1(t=0) = 0.1127$
- Ages 5-17: $R_2(t=0) = 0.1268$
- Ages 18-49: $R_3(t=0) = 0.2535$
- Ages 50-64: $R_4(t=0) = 0.5795$
- Ages 65+: $R_5(t=0) = 0.6762$

This same prior-immunity draw is held fixed across all four vaccination scenarios (A-D) for a given simulation iteration, so that any differences in outcomes between scenarios reflect vaccination assumptions rather than differing baseline immunity.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
The mean initial proportion of the population with any type of residual immunity across simulations was approximately 35.4% $\pm$ 1.7%.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
**Natural immunity waning details:**
The rate at which natural immunity wanes is dependent upon age class, following [Kucharski et al. 2015, Fig. 4](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1002082#pbio-1002082-g004):

- Ages 0-4: $\kappa_1= 1/(10/4.5*/4*365)$
- Ages 18-49: $\kappa_3= 1/(10/2*365)$
- Ages 50-64: $\kappa_4= 1/(10/1.75*365)$
- Ages 65+: $\kappa_5= 1/(10/1.5*365)$

**Vaccine-induced immunity waning details:**
Vaccine-induced immunity, $\epsilon$, wanes at a rate drawn from $1/(X \cdot 30)$ days$^{-1}$, where $X \sim \text{Triangular}(4, 8, 6)$ months, informed by [Ferdinands et al. 2017](https://academic.oup.com/c77?login=false).

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
No, the model considers only a single generic influenza strain/subtype.

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
N/A — no distinct subtypes are explicitly modeled. However, two historical reference seasons (2017-18, H3N2-dominant; 2019-20, H1N1-dominant) are used to bound uncertainty ranges for age-specific hospitalization-rate adjustment factors and vaccine effectiveness, since these seasons differed substantially in outcomes by age group (particularly ages 0-4 and 65+). These bounds are blended via uniform sampling within a single, subtype-agnostic parameter set, rather than assigning any individual simulation to a specific subtype.

### Are interactions between strains/subtypes/pathogens implicitly modeled?
No.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
The maximum value of $R_0$ is drawn uniformly between 1.8 and 2.0 for each simulation, and $\beta$ is calculated via the next-generation-matrix relationship $\beta=R_0/(\rho(M) \cdot D)$, where $\rho(M)$ is the dominant eigenvalue of the age-structured contact matrix $M$ and $D$ is the duration of infectiousness.

Seasonal transmission follows an early-season **up-ramp**: beta begins at a reduced baseline at simulation start (t=0, i.e., 2026-08-15) and rises to full strength by a randomly-drawn date between roughly 60 days after simulation start and January 30, 2027. A corresponding **down-ramp** later in the season gradually declines transmission from full strength back to the reduced baseline, with both a randomly-drawn start date (after January 30, 2027) and randomly-drawn end date (at least 14 days later, through mid-to-late spring 2027).

Independent of either ramp, a reduction in contact rates is applied specifically to age classes 0-4 and 5-17 during two fixed school-holiday windows:

- 2026-11-25 through 2026-11-29
- 2026-12-23 through 2026-01-03

These holiday reductions take precedence over the ramp trajectory regardless of where they fall relative to it.

## Initial Conditions
Infectious seeds are introduced weekly, by age class, over the first 17 weeks of the simulated period, following a ramp-then-plateau structure: seeding magnitude starts at 40% of its eventual weekly range in week 1 and rises linearly to the full range by week 4, then remains at the full range through week 17.

- Ages 0-4: 0 (not seeded)
- Ages 5-17: $X\sim U(1400,1600)$ at plateau 
- Ages 18-49: $X\sim U(2600,2800)$ at plateau
- Ages 50-64: $X\sim U(1400,1600)$ at plateau
- Ages 65+: $X\sim U(1400,1600)$ at plateau

Infectious seeding is matched across scenarios — i.e., `stochastic_run == 1` across Scenarios A, B, C, and D uses the identical weekly seeding draw — so that differences in outcomes across scenarios reflect vaccination assumptions rather than differing introduction events.

### Details on circulating strains at the start of the projection period or on how strains are introduced
See seeding description above; no distinct circulating strains are modeled (single generic strain).

### Details on pre-existing immunity (if applicable)
See *Immunity assumptions* above for age-specific prior-infection-derived immunity bounds. 

## Non-pharmaceutical interventions (NPIs)
N/A

## Age Group Variability
### Number of age groups
Five age groups were included in the model, following typical flu reporting conventions: 0-4, 5-17, 18-49, 50-64, 65+.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Age groups differ in their: proportion with prior immunity, vaccine effectiveness, hospitalization rates, hospital length of stay, and death rates. Age groups were also assigned different contact rates, informed by synthetic contact matrices from [Fumanelli et al. 2012](https://journals.plos.org=10.1371/journal.pcbi.1002673).

## State-level Variability
### Describe the spatial structure of the model, if any
The model represents the state of California as a single, non-spatially-structured population; no county- or sub-state-level geographic structure is included.

### Provide state-stratification details on calibrated parameters and initial conditions (e.g., prior immunity, R0)
This model submission is only for the state of California. Age-specific hospitalization and death-rate adjustment multipliers (relative to FluSurv-NET/HCAI baseline rates) were tuned specifically to California historical hospitalization and mortality data. 

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
The model assumes VE against infection is 50% of VE against hospitalization for a given age class $i$: $VE_{infection,i}= 0.5 \cdot VE_{hospitalization,i}$.

### VE against hospitalization given infection (by age, if relevant)
VE against hospitalization is sampled from a uniform distribution bounded by age-specific rates from two CDC Influenza Vaccine Effectiveness reference seasons:

- **H3N2:** 0.64 (0-4 y/o), 0.39 (5-17 y/o), 0.21 (18-49 y/o), 0.20 (50-64 y/o), 0.11 (65+ y/o) [2017-2018 season](https://archive.cdc.gov/#/details?url=https%3A%2F%2Fwww.cdc.gov%2Fflu%2Fvaccines-work%2F2017-2018.html) 
- **H1N1:** 0.34 (0-4 y/o), 0.38 (5-17 y/o), 0.34 (18-49 y/o), 0.40 (50-64 y/o), 0.39 (65+ y/o) [2019-2020 season](https://archive.cdc.gov/#/details?url=https%3A%2F%2Fwww.cdc.gov%2Fflu-vaccines-work%2Fphp%2Feffectiveness-studies%2F2019-2020.html)

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
The model assumes VE against onward transmission is negligible — vaccinated infected individuals are modeled as equally infectious as unvaccinated infected individuals.

### VE against mortality (if any effect beyond VE against infection and hospitalization)
The model does not explicitly include a separate VE term against mortality beyond its effects on infection and hospitalization risk.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
This model assumes a "leaky" vaccine, i.e., vaccinated individuals may still be infected or hospitalized, but at reduced rates relative to unvaccinated individuals.

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
Vaccination and infection-derived immunity are modeled as independent, mutually exclusive compartments ($V$ and $R$). Vaccine doses are subtracted from the Susceptible ($S$) compartment without distinguishing between individuals who are immunologically naive versus those who previously recovered and waned back into $S$. No explicit interaction or synergistic effect between vaccine-derived and infection-derived protection is modeled.

## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
Uncertainty is generated via both parameter sampling and implementation of the tau leap method itself.

**1. Parameter resampling (per simulation iteration, but shared across scenarios A-D for a matched iteration):**

- Peak $R_0$ ($R_{0,max}$)
- Incubation period, $\sigma$
- Recovery rate, $\gamma$
- Age-specific hospitalization rate adjustment factors
- Age-specific death-given-hospitalization rate adjustment factors (ages 50-64, 65+)
- Age-specific vaccine effectiveness against infection and against hospitalization
- Rate of loss of vaccine-induced immunity, $\epsilon$
- Age-specific prior-immunity fractions at simulation start
- Weekly infection-seeding magnitudes (weeks 1-17)
- Random season up-ramp end date, down-ramp start date, and down-ramp end date

**2. Aleatory uncertainty:**
Additional stochasticity arises from state transitions administered via the tau-leap method itself.

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
Relative to Round 6, the following changes were made for Round 7:

- Early-season transmission forcing was changed from a step function to a smoother, linear up-ramp and late-season down-ramp back to reduced baseline.
- Infection seeding was changed from a flat weekly range over weeks 1-16 to a ramp-then-plateau structure (lower magnitude in the first 4 weeks, rising to a higher sustained plateau through week 17), to better match the shape of early real-time hospitalization data.

## Other Model Assumptions
N/A