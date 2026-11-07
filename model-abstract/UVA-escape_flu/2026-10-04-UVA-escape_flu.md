# General Model Description
ESCAPE-Flu is a stochastic, full-population agent-based model. Each state (49 states and DC; Alaska is not modelled) is simulated on its own synthetic population and activity-based contact network (v2.4.0). Three influenza subtypes (A/H1N1, A/H3N2, B) are modeled as separate contagions. Each agent carries its own immune history: the date of last infection with each subtype, its vaccination record, and a long-term immunity flag. Protection is computed from these at every exposure and every severity decision. Simulations run at daily resolution from August 9, 2026 to June 5, 2027. Vaccination follows the hub's coverage curves with real timing. The national projection is the per-sample sum of the state projections.

# Summary of Results
National projections (sum of 49 states and DC; 300 paired trajectories per scenario) from October 4, 2026 to June 5, 2027. Values are medians with 80% projection intervals.

| Scenario | Hospital admissions | Peak weekly admissions | Peak week | Deaths (all, CDC scale) |
|---|---|---|---|---|
| A (optimistic coverage) | 344k (285k-399k) | 19k (14k-26k) | 2026-11-14 (2026-11-07 to 2027-02-06) | 50k (36k-72k) |
| B (usual coverage) | 397k (331k-457k) | 22k (17k-29k) | 2026-11-21 (2026-11-14 to 2027-02-06) | 58k (42k-82k) |
| C (no children's vaccination) | 479k (409k-546k) | 27k (21k-35k) | 2026-11-21 (2026-11-14 to 2027-01-23) | 70k (51k-98k) |
| D (no vaccination) | 638k (547k-729k) | 36k (28k-44k) | 2026-11-28 (2026-11-14 to 2027-01-23) | 97k (72k-138k) |

Paired scenario differences (per trajectory):
- Usual vaccination (B) compared with none (D): admissions -38.2% (90%: -40.8% to -36.3%)
- Usual vaccination (B) compared with none (D): deaths -40.0% (90%: -42.7% to -38.0%)
- Optimistic coverage (A) compared with usual (B): admissions -13.4% (90%: -15.2% to -12.0%)
- Optimistic coverage (A) compared with usual (B): deaths -13.6% (90%: -15.5% to -12.1%)
- Removing children's vaccination (C) compared with usual (B): admissions +21.0% (90%: +18.1% to +26.4%)
- Removing children's vaccination (C) compared with usual (B): deaths +19.0% (90%: +16.0% to +24.3%)

Deaths are all influenza deaths on the scale of CDC's in-season multiplier model: the model's in-hospital deaths scaled by age to CDC's all deaths per admission (see Other Model Assumptions).

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
Calibration uses NHSN weekly influenza admissions by state, all ages, through the hub's fitting cutoff of October 3, 2026, together with subtype percentages derived from NREVSS. No data after October 3 are used for fitting or selection. Calibration is done in two stages per state.

1. Retrospective fitting to previous season (2025-26). A 64-point Sobol design over 9 parameters is scored with a negative-binomial likelihood on weekly all-age admissions, plus a down-weighted (0.3) term on admissions split by subtype. Following parameters are calibrated: baseline transmissibility, seasonal amplitude, seasonal peak date and shape, background seeding, two subtype transmissibility weights and two subtype seasonal lags. Priors come from 2010-26 FluView subtype history.
2. Real-time fitting to current season (2026-27). From the 8 best fits, candidate 2026-27 parameters are drawn: a transmissibility multiplier (0.6-1.6), seasonal peak, subtype shares and seeding windows, per-subtype immune escape (0-0.3), and, in 8 states with an early H1N1 rise, an early H1N1 seeding pulse. Priors are informed by early-season evidence through October 3 (NHSN, NSSP and subtype data, using the HHS region where state data are missing). Candidates are simulated to October 10 and weighted by a tempered likelihood against NHSN admissions for the early weeks before the cutoff, including growth over the last weeks; the weighted candidates are then resampled.

The resampled members are run in full under scenario B and passed through a guardrail mechanism against past seasons. A run whose season total or peak exceeds the state's largest season since 2022-23 is deweighted (if > 1.5x) or excluded (if > 2x). A run whose admissions peak before November 1 is also excluded, since no state has peaked earlier in 2022-26 NHSN data. Sixty runs per state were kept in the first version of this submission (November 5).

**Update (November 6, 2026).** The vaccine was revised so that the simulated vaccine effectiveness matches the hub's 50% (see Vaccine Effectiveness and Model revisions). The stronger vaccine also shrinks the 2025-26 fit season, so the kept runs no longer fit it. Instead of recalibrating, each state's 60 runs were re-run with transmissibility (baseline and seasonal amplitude) multiplied by 1.16 and the probability of hospitalization by 1.08. In a Virginia test these factors restored the 2025-26 attack rate (1.15-1.18 across calibration runs) and admissions (1.04-1.13). The guardrail above was then re-applied to the re-run scenario B seasons. In the 16 states left with fewer than 45 runs, the surviving runs were resampled (each survivor equally, so a parameter set in proportion to how many of its runs survived) and re-simulated with the same parameters as new stochastic trajectories, then guarded again, until every state had at least 45 runs (190 new runs). The final ensemble has 45-59 runs per state (median 48). The early-season likelihood weighting was not redone. The kept runs are projected under scenarios A, C and D with identical parameters.

# Model Assumptions
## Immunity assumptions
Immunity is per agent and per subtype, not compartmental. Protection against infection has four parts:

- protection from the last infection with the same subtype;
- cross-protection between H1N1 and H3N2 (0.20 in each direction; none between A and B);
- long-term immunity;
- vaccine protection.

Infection-derived and vaccine-derived protection are separate multiplicative terms.

### Number/type of immune classes considered
Immunity is continuous rather than divided into classes. Each agent has a last-infection date per subtype (3 clocks), a last-dose date and formulation, and a long-term immunity flag. After infection an agent is fully protected against that subtype for about 6 months (refractory R state, normal duration with mean 180 days, sd 30). It then returns to S with protection that wanes from 70%.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
The median S0 on October 4, 2026 across kept runs is 0.73 (5-95%: 0.68-0.76). State medians range from 0.69 to 0.76. By subtype the medians are H1N1 0.73, H3N2 0.71 and B 0.72. Residual immunity is therefore about 27%, ranging from 24% to 32%.

### How is variability in this parameter engineered, if any?
S0 varies across runs through three parts:

- the next-season immune escape draw (0-30% per subtype), applied as 1 - (1 - S0)(1 - escape);
- the long-term immune fraction, solved per run so that S0 on October 4 matches the run's source calibration run;
- each run's own infections between August 9 and October 4.

The infection history used to build the initial condition is the same in all runs of a state.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
See above: median S0 0.73 (5-95%: 0.68-0.76), so residual immunity is about 27%.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
Yes, and it differs by source. Infection-derived protection wanes exponentially with a 1-year half-life. Vaccine-derived protection wanes with a 150-day half-life. Infection-derived protection is further reduced by antigenic drift of about 16% per year, counted from the infection date. Since the November 6 update, vaccine protection has no drift term: the hub's VE assumption already covers the match of the 2026-27 vaccine. Vaccine protection wanes only with time since the dose. Long-term immunity (80% protection, in a fraction of adults and half as many children) does not wane.

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
Yes: A/H1N1, A/H3N2 and B, are modeled as separate contagions.

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
Each subtype has its own:

- transmissibility weight;
- seasonal lag relative to the shared seasonal forcing;
- seeding window;
- next-season immune escape (0-30%);
- infection history;
- severity, through within-age relative hospitalization ratios (H3N2 0.76-0.93x and B 0.69-0.95x H1N1 by age, from FluSurv-NET 2010-19, Sumner et al. 2023) and in-hospital death ratios by subtype and age.

Subtype shares for 2026-27 are sampled with H1N1 favored (0.45-0.85 of the season), consistent with early-season laboratory data (about 89% of subtyped A was H1N1 through October 3).

### Are interactions between strains/subtypes/pathogens implicitly modeled?
Yes, explicitly. Infection with H1N1 protects against H3N2 by 0.20 and vice versa, waning like homologous protection. Co-infection with different subtypes is allowed, and death from any subtype removes the agent.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
Seasonality is a cosine forcing of transmissibility with a sampled peak date and shape (power 1-4). It stands in for environmental and behavioural drivers. Each subtype is offset by its own sampled lag. The 2026-27 peak of the forcing is sampled separately from the fit-season peak.

## Initial Conditions
Simulations start on August 9, 2026 from each state's synthetic population. Every agent carries per-subtype last-infection dates and a vaccination history. Infections from October 2022 to August 2026 are back-calculated from NHSN admissions using subtype- and age-specific infection-hospitalization ratios. The subtype split comes from FluView laboratory data, tilted by age, and season totals are checked against CDC burden estimates. Vaccination history (2022-23 to 2025-26 campaigns) is sampled by state and age with correlated individual vaccination propensity, so habitual vaccinators are repeat vaccinees.

### Details on circulating strains at the start of the projection period or on how strains are introduced 
Strains are introduced by a background seeding hazard in subtype-specific windows. H1N1 seeding starts from the simulation start, H3N2 and B later. In 8 states with an early H1N1 rise (FL, CA, WA, LA, MT, AL, TN, UT), an additional early H1N1 seeding pulse is sampled. By October 4, H1N1 dominates in most runs.

### Details on pre-existing immunity (if applicable)
Pre-existing immunity comes from the reconstructed infection and vaccination histories described above, plus a long-term immune fraction (80% protection, adults; children half the fraction). That fraction is solved per run and per subtype so that S0 on October 4 matches the run's source calibration run. See the S0 values above.

## Non-pharmaceutical interventions (NPIs)
None. There are no NPIs and no imposed behaviour change; the only time-varying transmission terms are seasonality and population immunity.

## Age Group Variability
### No of age groups
Agents have individual ages. Severity and outputs use the hub's 5 age groups (0-4, 5-17, 18-49, 50-64, 65+).

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Susceptibility does not depend on age; age differences in infection come from the contact network. Long-term immunity is half as common in children. Vaccine effectiveness and waning are the same at all ages. The probability of hospitalization given infection is age-specific: an NHSN-anchored ladder of 0.58% / 0.36% / 0.46% / 0.82% / 5.8% for H1N1 from 0-4 to 65+. It is re-anchored per state so that model admissions by age match NHSN 2024-26 age shares. The probability of death given hospitalization is age- and subtype-specific (FluSurv-NET in-hospital deaths). Submitted deaths are scaled from these in-hospital deaths to all flu deaths, by age, to match CDC's in-season multiplier-model estimates (see Uncertainty and Other Model Assumptions).

## State-level Variability
### Describe the spatial structure of the model, if any
Each state is simulated on its own synthetic population and contact network, so spatial structure within a state emerges from the network. States are independent, with no travel or commuting between them. The national projection is the per-sample sum of the 49 states and DC (no Alaska).

### Provide state-stratification details on calibrated parameters and initial conditions (eg, prior immunity, R0)
The following are all state-specific:

- every calibrated parameter (transmissibility, seasonal amplitude, timing and shape, subtype weights, lags and seeding, next-season multipliers and escape);
- the infection and vaccination histories;
- the long-term immune fraction;
- the age multipliers on hospitalization.

The early H1N1 seeding pulse is used in 8 states.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
43% at full strength, at all ages, waning with a 150-day half-life from the dose. Because the vaccine is leaky and agents are exposed repeatedly over the season, realized VE against infection in simulation is lower: about 23% over the season in a matched-cohort analysis of simulated vaccinees (Virginia, scenario B). The first version of this submission used 25% at full strength, which also drifted with time since the formulation date; its realized VE against infection was about 10%.

### VE against hospitalization given infection (by age, if relevant)
The vaccine reduces the probability of symptomatic illness given infection by an additional 46% at full strength, with the same waning. Hospitalization occurs only from symptomatic infection, so there is no separate term for hospitalization given infection: VE against hospitalization equals VE against symptomatic (medically attended) illness. That is 1 - (1 - 0.43)(1 - 0.46) = 69% at full strength. Realized over the season, in the same matched-cohort analysis, it is about 49% against symptomatic illness and 52% against hospitalization, matching the hub's 50% against medically attended illness and hospitalization. The first version of this submission used 33% against hospitalization given infection on top of the infection term; its realized VE against hospitalization was about 33%.

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
None beyond the reduction in infection.

### VE against mortality (if any effect beyond VE against infection and hospitalization)
None beyond the reductions in infection and hospitalization. In this model all deaths arise from those that are hospitalized.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky.

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
Vaccine and infection protection are independent multiplicative terms: an agent's susceptibility is (1 - vaccine protection) x (1 - infection protection). Vaccine protection does not depend on prior infection. Susceptible, exposed, asymptomatic and recovered agents are all eligible for vaccination, and doses go preferentially to habitual vaccinators.

## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
1. Yes. Fit-season parameters come from the 8 best fits of a 64-point Sobol design. Next-season parameters (transmissibility multiplier, seasonal peak, subtype shares, lags and seeding, immune escape, early H1N1 pulse) are drawn from priors. These are reweighted by early-season likelihood, resampled, and filtered by the guard on past-season size and peak timing. After the November 6 update (re-run with the revised vaccine, guard re-applied, states below 45 runs topped up by re-simulating resampled surviving runs and guarding them again) 45-59 runs per state are kept (median 48).
2. Yes:
   - Each simulation is stochastic: transmission, natural history, vaccination uptake and severity events.
   - Each state's runs are expanded to 300 trajectories by severity replicates, ceil(300 / runs) per run (6 to 7 per run, by state). The first replicate (stochastic_run 1) is the run as simulated. The others rescale admissions by drawn subtype, age and state severity multipliers and by weekly AR(1) noise from October 4 on, preserving totals through the cutoff.
   - Deaths are computed from each trajectory's admissions with a perturbed probability of death given hospitalization and a 3-14 day delay. These in-hospital deaths are then scaled to all deaths by an age-specific ratio, with a drawn national level (log-sd 0.20, the spread across 2022-26 seasons) and age profile.
   - The same draws are used in all four scenarios, so trajectories are paired across scenarios, ages and targets (run_grouping = run, stochastic_run = replicate).
   - Severity draws have a national component shared across states within a national sample.

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
The first escape-flu model for a SMH submission was in 2024 and it used the same simulation engine and populations, as well as a similar disease model, however, the calibration and projection approach were a bit different.  Additionally, this escape-flu model uses 3 independent pathogen contagions (the first multi-contagion submission).  These are simultaneously simulated and the two A types have cross immunity with eachother.  Additionally, this escape-flu model uses and individualized immune history approach that allows waning to be assessed at the individual level and to vary based on source of last immunizing event.  This was adapted from the ESCAPE-COVID model submitted to COVID-19 SMH Round 20 (per-agent immune clocks, waning and escape). 

Some specific details for the flu model:
- three subtype contagions with cross-protection;
- subtype- and age-specific severity from FluSurv-NET;
- histories built from infections back-calculated from NHSN admissions;
- cosine seasonality with subtype lags;
- a two-stage calibration with early-season selection and a guardrail approach based on past seasons.

Update of November 6, 2026 (this version replaces the projections of November 5):
- The vaccine has no antigenic drift term; protection wanes only with time since the dose.
- VE against infection was raised from 25% to 43% at full strength.
- VE now acts on symptomatic illness (46%) instead of on hospitalization given infection (was 33%). Realized VE in simulation is about 23% against infection, 49% against symptomatic illness and 52% against hospitalization, versus about 10%, 10% and 33% before.
- To keep the 2025-26 fit, the kept runs were re-run with transmissibility x1.16 and hospitalization probability x1.08, and the guardrail was re-applied. States left with fewer than 45 runs were topped up by re-simulating resampled surviving runs (same parameters, new stochastic trajectories) and guarding them again. This leaves 45-59 runs per state instead of 60 (like in the original submission).
- The stronger vaccine corrects an under estimate and thus increases the projected effect of vaccination: scenario B versus D is -38.2% in admissions, versus -19.7% in the first version.

## Other Model Assumptions
Deaths are scaled to the hub's target, CDC's in-season multiplier-model estimate of all flu deaths, in post-processing; no simulation was re-run. The model's in-hospital deaths (FluSurv-NET P(death | hospitalized) applied to model admissions, ~0.03 per admission) are multiplied by age-specific ratios of all deaths to in-hospital deaths (overall ~4.9x). The ratios come from CDC's in-season cumulative death estimates for 2022-23 to 2025-26 (geometric mean of the 95% bounds) divided by NHSN admissions over the same weeks, which gives 0.14 all deaths per admission (range 0.11-0.18 by season). The age profile comes from CDC's final burden estimates of deaths per hospitalization (2022-25). CDC's final estimates have been lower than its in-season ones (0.08-0.12 per admission), so our deaths may be high relative to final burden estimates. The scaling is the same in all four scenarios, so the scenario differences in deaths follow admissions. Alaska is not modelled and the national total excludes it. Infections lean toward school-age children because of the activity-based contact network; hospitalizations by age are anchored to NHSN.
