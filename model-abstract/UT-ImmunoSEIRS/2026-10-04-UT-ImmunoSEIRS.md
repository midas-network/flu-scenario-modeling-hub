# General Model Description
The updated ImmunoSEIRS model is an age-structured SEIRS-type compartmental model with additional hospitalization, recovery, and death pathways. It simulates influenza transmission and disease burden in six age groups (0–4, 5–11, 12–17, 18–49, 50–64, and 65+ years) for the United States and individual states. The model incorporates age-specific contact matrices, school and work calendars, and state-specific absolute humidity data from NOAA to represent seasonal changes in influenza transmission. The updated model no longer uses the pooled population-immunity variables (M) employed in earlier versions. Instead, the recovered compartment (R) represents pre-existing population immunity at initialization, assumed to reflect residual protection from prior infections and vaccinations. During model simulation, individuals enter R following recovery from infection and leave R as immunity wanes. Current vaccination is incorporated directly through age-specific coverage and vaccine effectiveness against infection and against hospitalization given infection. The model generates 300 parameter-perturbed trajectories per vaccination scenario

# Summary of Results
Projected influenza epidemic timing and magnitude vary across geographic locations and vaccination scenarios. National projections show the lowest hospitalization burden under Scenario A (optimal vaccination), followed by Scenario B (usual vaccination), Scenario C (adult-only vaccination), and Scenario D (no vaccination). Variability in calibrated infection- and death-rate parameters generates a range of projected outcomes. Initial immunity and its waning influence the susceptible population and epidemic dynamics.

# Model Calibration
## Describe which datasets are used for calibration, which years of data are used, and what is the calibration method
The model is calibrated separately for the United States and each state using observed influenza-associated hospitalization data from August 23, 2025, through October 3, 2026 (approximately 59 weeks). Age-specific vaccination coverage, state-specific absolute humidity, age-specific contact matrices, and school and work calendars are incorporated as model inputs. As in the previous submission, model calibration uses Python’s scipy.optimize.curve_fit to minimize squared differences between simulated and observed hospitalization trajectories, with iterative adjustment of model parameters and initial conditions. The Levenberg–Marquardt algorithm is used when fitting without parameter bounds. In addition, immunity initialization and waning assumptions were examined using the preceding two influenza seasons to identify epidemiologically reasonable conditions for the 2026–27 projections.

# Model Assumptions
## Immunity assumptions
Pre-existing population immunity is represented through the recovered compartment (R), initialized to reflect aggregate residual protection from previous infections and seasonal vaccinations. During simulation, R gains individuals through recovery following infection and loses individuals through immunity waning back to susceptibility. Vaccination does not directly transfer individuals into R; instead, age-specific vaccination coverage and vaccine effectiveness reduce infection and hospitalization risks. Vaccination can indirectly alter R accumulation by changing the number and clinical pathways of infections.

### Number/type of immune classes considered
The model explicitly includes susceptible (S) and recovered (R) states, in addition to exposed, infectious, hospitalization, recovery-pathway, and death states. R is the model’s explicit residual-immunity state.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
An initial immune proportion of approximately 24% was assumed at the beginning of the calibration exercise. Simulations examining immunity dynamics over the preceding two seasons, under 6.5 and 8 month waning half-life assumptions, yielded approximately 27%–34% in R at the beginning of the 2026–27 projection period. This is interpreted as aggregate residual population immunity from previous infections and vaccinations at initialization, not as a separately identified vaccine-derived fraction. Values may differ across geographic calibrations.

### How is variability in this parameter engineered, if any?
The initial immune proportion was evaluated through sensitivity analyses of the waning assumption (between 6-8 months) and the resulting immunity dynamics across preceding seasons. It is not independently perturbed in the 300 parameter-perturbed projection simulations, based on the currently described implementation.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2026-27 season.
Approximately 27%–34% in Recovered compartment at the beginning of the 2026–27 projection period.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
Yes. Immunity represented in Recovered (R) class wanes continuously, returning individuals to S (Susceptible). Waning half-lives of 6.5 and 8 months were evaluated. The updated model does not explicitly distinguish infection-derived and vaccine-derived immunity in separate waning compartments.

## Details on Influenza Strain(s)
### Does the model include distinct (sub)types, or distinct pathogens?
NA

### What is specific to each (sub)type or pathogen modeled? (immune escape, transmissibility)
NA

### Are interactions between strains/subtypes/pathogens implicitly modeled?
No explicit strain–strain or pathogen–pathogen interactions are modeled. Influenza circulation is represented in aggregate.

## Seasonality implementation
### How is seasonality modelled? (e.g., environmental factors or human contact)
Seasonality is modeled using state-specific NOAA absolute humidity data, age-specific contact matrices, and school and work calendars.

## Initial Conditions
Projection begins on October 4, 2026, from the age-specific compartment states carried forward at the end of calibration on October 3, 2026. These include susceptible, exposed, infectious, recovered, and other disease-progression states. Initial R reflects the chosen aggregate pre-existing immunity assumption and its preceding dynamics.


### Details on circulating strains at the start of the projection period or on how strains are introduced 
The model does not separately seed influenza subtypes. Circulation at projection start is represented by the exposed and infectious populations carried forward from the calibration period; subsequent circulation follows the transmission and seasonality assumptions.

### Details on pre-existing immunity (if applicable)
Pre-existing immunity is initialized through R as an aggregate assumption reflecting residual protection from previous infection and vaccination. Approximately 24% initial immunity was used at the beginning of the calibration exercise; evaluating prior-season dynamics with alternative waning assumptions resulted in approximately 27%–34% in R at the start of the 2026–27 projections. During simulation, new entry into R is through infection recovery, while vaccine protection acts directly on infection and hospitalization risks.

## Non-pharmaceutical interventions (NPIs)
NA

## Age Group Variability
### No of age groups
Six: 0–4, 5–11, 12–17, 18–49, 50–64, and 65+ years.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
The model uses age-specific contact matrices, vaccination coverage, infection-hospitalization risks, and hospitalization and mortality pathways. Age-specific epidemic states can differ. For these projections, vaccine effectiveness against infection (21%) and against hospitalization given infection (37.5%) is assumed constant across age groups. The examined immunity-waning assumptions are shared across age groups.


## State-level Variability
### Describe the spatial structure of the model, if any
The model is run separately for the United States and each of the 50 states, with geography-specific hospitalization observations, vaccination inputs, environmental conditions, and fitted epidemic trajectories. Explicit interstate movement or coupled transmission is not modeled.

### Provide state-stratification details on calibrated parameters and initial conditions (eg, prior immunity, R0)
Geographic calibrations allow differences in transmission- and severity-related parameters and age-specific initial compartment states. State-specific absolute humidity, vaccination coverage, and observed hospitalization patterns contribute to geographic variability. IHRs calibrated for national level are assumed to remain same for all states. Initial residual immunity is informed by the immunity initialization and waning assessment; the exact state-specific values are determined by the corresponding model setup and calibrated state. No independently specified state-specific R0 values are asserted here.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
VE against infection is 21% for all age groups. The new-infection term is reduced by the coverage-weighted factor (1 − VE_I × age-specific vaccination coverage).

### VE against hospitalization given infection (by age, if relevant)
VE against hospitalization conditional on infection is 37.5% for all age groups. The infection-to-hospitalization pathway is reduced by the coverage-weighted factor (1 − VE_H/I × age-specific vaccination coverage), in addition to the effect of preventing infections.

### VE against transmission (if any effect beyond VE against infection; by age, if relevant)
No additional reduction in infectiousness conditional on infection is modeled. Vaccination can reduce onward transmission indirectly by preventing infections.

### VE against mortality (if any effect beyond VE against infection and hospitalization)
NA. No separate VE against mortality is modeled.

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky

### How does the vaccine interact with prior immunity (for instance, does vaccine protection depend on prior immunity, and how)?
At initialization, R is assumed to represent aggregate residual protection associated with previous infections and vaccinations. During simulation, R is populated through infection recovery; current vaccination reduces infection and hospitalization risks directly through VE_I and VE_H/I. Vaccination thereby also changes the subsequent
accumulation of infection-acquired immunity indirectly. No separate interaction term for hybrid immunity is explicitly modeled.


## Uncertainty
### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
For each vaccination scenario, 300 simulations are generated using a fixed set of random seeds. Normally distributed random disturbances are added around fitted x0 and z0 parameters governing the infection rate (beta) and death rate, respectively. Each sampled parameter realization is propagated through the same deterministic compartmental equations to produce a hospitalization trajectory. No additional event-level stochasticity is introduced beyond parameter perturbation.

## Model revisions
### Summarize important changes to the model compared to prior SMH submissions
The main change is removal of the previous pooled population-immunity formulation, which used explicit M-type immunity variables and mass-action-style modifiers for protection against infection and severe outcomes. The updated age-stratified SEIRS-type model instead represents aggregate pre-existing immunity through the initial recovered state (R), while current vaccine protection is applied directly to the infection and infection-to-hospitalization pathways using VE against infection and VE against hospitalization given infection.The recovered state subsequently accumulates individuals through infection recovery and wanes back to susceptibility. This approach simplifies the mapping of vaccination coverage and effectiveness inputs to model mechanisms. The change is a refinement suited to current influenza data and modeling objectives. The updated implementation includes hospitalization and death pathways and generates 300 parameter-perturbed trajectories using normally distributed disturbances around fitted infection- and death-rate parameters. Age-specific contact matrices, school and work calendars, and state-specific absolute humidity inputs are retained from the earlier framework.

## Other Model Assumptions
NA
