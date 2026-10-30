# General Model Description
A deterministic compartmental model with three co-circulating strains (A/H1N1pdm09, A/H3N2, B) and five age groups (0-4, 5-17, 18-49, 50-64, 65+), run for the US and for each of the 50 states and DC. Per age and strain: susceptible → infectious (no exposed class; 3.5-day infectious period) → recovered → susceptible again as infection-induced immunity wanes; susceptible → vaccinated (leaky protection, from the scenario coverage curves) → susceptible as vaccine protection wanes. Infection with one A subtype moves people, vaccinated or not, into a partially cross-protected class against the other A subtype, which wanes over months. A hospital pipeline converts infections into admissions by age and strain and admissions into deaths. Contacts are age-structured by setting (home, school, work, other) and follow a fixed school and holiday calendar. Parameters that describe the virus or the vaccine (effectiveness, waning, cross-protection, severity by age and strain, strain transmissibility ratios, holiday mixing) are shared across locations; parameters that describe the population (H1N1 reproduction number, starting susceptibility and seeding by strain, reporting scale, noise) are specific to each location. An interactive page shows the calibration, every parameter with its fitted value and 95% range, and the scenario trajectories, and re-solves the model in the browser when parameters are changed: https://scc-usc.github.io/SMH-web/Flu2026-27_Round1/

# Summary of Results
Across 300 paired trajectories, the model projects a 2026-27 season of a similar size to the two seasons it was calibrated to. Nationally, scenario B (coverage as in 2024-25) gives a median of 540,000 reported hospital admissions from October 4, 2026 to June 5, 2027 (5–95%: 480,000–617,000), between the 541,000 observed from November 2024 to June 2025 and the 322,000 observed in 2025-26. Vaccination averts about 80,000 admissions nationally relative to the no-vaccination counterfactual (scenario D, median 619,000), and the optimistic pre-pandemic coverage of scenario A averts about 100,000. Stopping childhood vaccination (scenario C) adds about 10,000 admissions over scenario B; its indirect effect is small because the estimated vaccine effectiveness against infection is low (about 2%), so nearly all of the vaccine's benefit in the model comes from protection against hospitalization given infection, which the hub fixes at 50%. Peaks fall in late December in most trajectories, with the timing spread (early December to early January) driven by the year-to-year variation in the timing of the pre-holiday surge. Projected national deaths under scenario B are 68,000 (47,000–99,000). The same ordering of scenarios holds in every state.

The projected season is the result of (i) the susceptibility left after the two calibrated seasons, with H3N2 and B more depleted than H1N1 after the H3N2-dominated 2025-26 season, (ii) estimated transmissibility (H1N1 R0 about 1.7 nationally; H3N2 and B 1.4 and 1.3 times as transmissible), and (iii) the seasonal contact calendar, in which the estimated pre-holiday mixing window in mid-December (other contacts × 1.6) triggers the main wave and the school winter break ends it. Because vaccine effectiveness against infection is estimated to be low, vaccination changes the epidemic's course very little; its effect is almost entirely a reduction of hospitalizations given infection, so the scenarios differ in size but hardly in timing. The spread between trajectories comes from parameter uncertainty (which season-to-season variation the two calibrated seasons do not pin down), from the timing of the pre-holiday surge, which the model draws from 14 past seasons, and from reporting noise.

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
Datasets: weekly NHSN hospital admissions by age group for every location (negative binomial likelihood with a location-specific dispersion), national public health laboratory subtype shares (Dirichlet-multinomial), and the CDC seasonal death estimate ranges for 2024-25 and 2025-26 (log-normal constraints on cumulative deaths). Years: the two seasons from November 9, 2024 (first week of NHSN admissions by age) to October 3, 2026, calibrated jointly for all 52 locations. Method: the exact ODE for all locations is solved in one batched GPU computation and optimized by L-BFGS with exact gradients, in stages (national, then all states with shared parameters fixed, then everything jointly), followed by Newton steps on the exact Hessian. Priors from the literature are placed on all parameters, with hard bounds on vaccine effectiveness against infection (2–32%), vaccine protection duration (4–8 months) and infection-induced immunity (6 months – 3 years). Parameter uncertainty is the curvature (Laplace approximation) at the optimum. The browser version of the model is checked against the calibration code on every page load.

# Model Assumptions
## Immunity assumptions
Immunity from infection is strain-specific and complete while it lasts, then returns the person to fully susceptible (fitted mean duration about 3 years, at the upper bound of its prior; this term also absorbs antigenic drift). Vaccination gives leaky partial protection against infection that wanes (fitted mean 5 months). Infection with one A subtype gives partial protection against the other (fitted 70%, waning over about 6 months), for vaccinated and unvaccinated people alike.

### Number/type of immune classes considered
Per age group and strain: recovered (fully immune), vaccinated (leaky), cross-protected (A subtypes only, partial), and vaccinated-and-cross-protected (A subtypes only, both reductions combined).

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
The model runs continuously from November 2024, so the state at the start of the 2026-27 season follows from the calibrated dynamics of the two preceding seasons rather than being set separately. At the start of the projection period (October 2026) the national S0 by the hub's definition (partially protected groups weighted by their remaining susceptibility, subtypes weighted by their cumulative infection shares) has a median of 0.63 across trajectories: 0.75 for H1N1, 0.54 for H3N2 and 0.50 for B. Residual vaccine protection from the 2025-26 vaccination is carried over from the coverage curves with the fitted waning.

### How is variability in this parameter engineered, if any?
Starting susceptibility per location and strain at the start of the calibration window (November 2024) is a calibrated parameter with a shared age profile; each of the 300 trajectories draws it, with all other parameters, from the curvature of the fit, and the residual immunity in October 2026 varies across trajectories accordingly.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
See above.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
Yes, and it differs: vaccine protection wanes with a fitted mean of about 5 months (bounded 4–8 months), infection-induced immunity with a fitted mean of about 3 years (bounded 6 months – 3 years), and cross-protection between A subtypes with a fitted mean of about 6 months.

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
Three distinct influenza (sub)types, co-circulating: A/H1N1pdm09, A/H3N2 and B. No other pathogens.

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
Each strain has its own susceptible, infectious and recovered classes per age group, its own starting susceptibility and seeding per location, and its own transmissibility: H1N1's basic reproduction number is estimated per location (about 1.7 nationally); H3N2 and B are 1.38 and 1.28 times as transmissible, estimated jointly for all locations. Hospitalizations per infection are estimated by age for H1N1, with estimated age-specific multipliers for H3N2 and B. No antigenic change is assumed for 2026-27; the projected strain mix follows from the remaining susceptibility to each strain.

### Are interactions between strains/subtypes/pathogens implicitly modeled?
Explicitly: infection with one A subtype gives partial, waning cross-protection against the other (fitted 70% for about 6 months). No cross-protection between A and B. The strains also interact through the hospital pipeline and the shared reporting scale, but not through contacts or behavior.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
Through human contact only, with a fixed calendar rather than a climate term. Age-structured contacts by setting (home, school, work, other): school contacts are switched off over the winter break (December 21 – January 4) and the summer break (June 15 – August 24); a pre-holiday mixing window (December 8–24) multiplies 'other' contacts by an estimated factor (fitted 1.6); an estimated factor applies to work and other contacts during the winter break (fitted 0.97). The dates come from an analysis of when growth rates jump consistently across 676 ILINet location-seasons (2010–2026) and 129 NHSN location-seasons. For the projection, each trajectory shifts the 2026-27 pre-holiday window by the surge timing of one of 14 past seasons relative to 2025-26 (from 24 days earlier to 5 days later), so the timing of the coming season's surge carries the historical spread.

## Initial Conditions
The model runs continuously from November 9, 2024 through the projection period; the state at the start of the projection (October 4, 2026) follows from the calibrated dynamics through October 3, 2026, including the vaccination of September 2026. Vaccination through October 3, 2026 follows scenario B's coverage in every scenario, so all scenarios share the same initial conditions, as the hub requests; the scenarios diverge from October 4, 2026, with no vaccination at all in scenario D thereafter.

### Details on circulating strains at the start of the projection period or on how strains are introduced 
Strains are not introduced; all three circulate continuously from the seeding at the start of the calibration window (November 2024, estimated per location and strain). At the start of the projection period the national lab subtype shares through late September 2026 show H1N1 as the majority of positives with H3N2 second and little B; the model's strain mix at that point matches these shares, and its strain-specific susceptibility reflects the H1N1/H3N2 co-dominant 2024-25 season and the H3N2-dominated 2025-26 season.

### Details on pre-existing immunity (if applicable)
Pre-existing immunity at the start of the projection is the calibrated state: recovered (fully immune) by strain and age from the two calibrated seasons, residual vaccine protection from the 2025-26 and September 2026 vaccination, and cross-protection between the A subtypes. At the start of the calibration window (November 2024) the susceptible fraction per location and strain is estimated, with a shared age profile, together with an estimated fraction of A-susceptibles that are cross-protected; leftover vaccine protection from the 2023-24 season is set from the coverage curve with the fitted waning.

## Non-pharmaceutical interventions (NPIs)
None.

## Age Group Variability
### No of age groups
Five: 0-4, 5-17, 18-49, 50-64, 65+.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Age-structured contacts by setting; an estimated age profile of starting susceptibility by strain; hospitalizations per infection by age and strain, and deaths per admission by age (fixed profile, scaled by an estimated level). Vaccine effectiveness and waning do not differ by age; vaccine coverage does, following the hub's age-specific coverage curves.

## State-level Variability
### Describe the spatial structure of the model, if any
Each state (and DC, and the US as a whole) is an independent, well-mixed population with its own age structure; there is no transmission or movement between states. The locations are coupled only through the parameters they share in the calibration.

### Provide state-stratification details on calibrated parameters and initial conditions (eg, prior immunity, R0)
Each state has its own calibrated H1N1 reproduction number (H3N2 and B follow by the shared ratios), starting susceptibility and seeding by strain at the start of the calibration window, reporting scale and noise dispersion, and uses the hub's state-specific coverage curves. Virus and vaccine parameters (effectiveness, waning, cross-protection, severity by age and strain, strain transmissibility ratios, holiday mixing, the age profile of starting susceptibility) are shared by all states. The state's immunity at the start of the projection follows from its own calibrated dynamics.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
Estimated: 2.4% (95% range 2.1–3.1%) with a hard lower bound of 2% and an upper bound of 32%; fits that were free to choose consistently preferred values near 2%. The same value applies to all ages and strains and to all scenarios.

### VE against hospitalization given infection (by age, if relevant)
About 49% for all ages and strains: vaccinated people who are infected are hospitalized with a reduced probability, set so that the overall VE against hospitalization (infection and hospitalization given infection combined) is exactly the hub's 50% whatever the estimated VE against infection.

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
None beyond the reduction of infections.

### VE against mortality (if any effect beyond VE against infection and hospitalization)
None: deaths in the model follow admissions with a fixed age profile.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky, for both protection against infection and protection against hospitalization given infection.

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
Vaccine protection does not depend on prior immunity. Vaccination moves susceptible people (including cross-protected ones) into vaccinated classes; recovered people, who are fully immune, are unaffected by vaccination until their immunity wanes. A vaccinated person who is also cross-protected against the other A subtype has both reductions combined multiplicatively. Vaccinated people who get infected become fully immune on recovery, as unvaccinated people do.

## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
1. Yes: all 555 model parameters (shared and location-specific) are drawn jointly from the Gaussian curvature (Laplace) approximation at the calibrated optimum; each of the 300 draws is used for all four scenarios, so trajectories are paired. In addition, each draw shifts the 2026-27 pre-holiday mixing window by one past season's surge timing. 2. Reported admissions carry negative-binomial reporting noise sampled once per trajectory with the location's fitted dispersion (the same noise across the paired scenarios is not imposed; noise is sampled per trajectory and scenario). The transmission model itself is deterministic.

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
This is the first Scenario Modeling Hub submission of this model; there are no prior submissions to compare with.

## Other Model Assumptions
Reported admissions are modeled as the model's admissions times a location-specific reporting scale. The hospital pipeline uses a mean of one week from infection to admission and 1.5 weeks from admission to death. The 2024-25 and 2025-26 vaccination coverage curves are the hub's scenario B curve placed one and two years earlier (the hub provides no historical curves). The model fits the national peaks of both calibrated seasons imperfectly (it undershoots the February 2025 peak by about 30% and the January 2026 peak by about 20%) and attributes a larger share of severity to H1N1 than the literature suggests; both are known limitations of this submission.
