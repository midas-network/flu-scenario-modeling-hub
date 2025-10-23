# Summary of Results
Without any vaccination, peak weekly incident admissions could exceed peaks of last three influenza seasons in California.

Maximum peak size counterfactual (6,100 weekly incident  admissions):
Low vaccination: 2,200 peak admissions; ↓ 63% reduction
Usual vaccination: 1,600 peak admissions; ↓ 73% reduction

Scenarios with any level of vaccination reduce cumulative burden relative to counterfactual (no vaccination) and below last season’s cumulative burden.

Cumulative hospitalizations counterfactual (46,350 total admissions):
Low vaccination: 25,600 admissions; ↓45% reduction
Usual vaccination: 19,600 admissions; ↓ 57% reduction

# General Model Description
This model provides scenarios for the state of CA only. The model is a stochastic, mechanistic model implemented via the tau leap method with the following state variables:

- Susceptible = $S(t)$
- Vaccinated = $V(t)$
- Exposed: Unvaccinated= $E(t)$
- Exposed: Vaccinated= $E_v(t)$
- Infected: Unvaccinated = $I(t)$
- Infected: Vaccinated= $I_v(t)$
- Hospitalized= $H(t)$
- Dead= $D(t)$
- Recovered= $R(t)$

Scenario results are based on a sample size of 300 simulations per scenario. 

# Explanation of observed dynamics given model assumptions
Vaccination even at lower coverage level provides additional indirect benefits in hospitalization burden averted. 
For example, when assuming usual vaccination coverage (46% coverage nationally), these California specific scenarios predict a 57% reduction in cumulative hospitalization burden.

# Model Calibration
The model was calibrated by adjusting the seeding conditions in order to match historical California Department of Health Care Access and Information (HCAI) hospitalization data disaggregated by age class. Please see *Initial Conditions* description below.


# Model Assumptions
## Immunity assumptions

### Number/type of immune classes considered
Individuals can be either Recovered, $R(t)$ (immunity due to prior infection), or Vaccinated, $V(t)$ (from vaccination during current season). This model does not track immunity status resulting from different flu types or sub-types.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2025-26 season. 
Initial proportions with residual immunity were calculated as a function of the age class population and the frequency with which different age classes experience flu infection (captured by the \kappa values described in the "Natural immunity waning details below"). More specifically, these values were calculated by solving a series of linear equations:

$0.054R_1+ 0.167R_2+ 0.442R_3+0.185R_4+0.153R_5= R(t=0)$ where the coefficients correspond to the relative proportion of the population in each age class, $R_i$ corresponds to the initial proportion of that age class that is immune, and $R(t=0)=0.30$ or $0.15$ per scenario specifications.
$R_i$ is then proportional to the rate of natural immunity waning for age class $i$, $\kappa_i$, such that for example:
 $r= \kappa_2/\kappa_1$ & $R_2 = rR_1$.
 
### How is variability in this parameter engineered, if any?

For each age class, prior immune status was sampled as uniform distribution with the min and maximum bounds defined by the low and high immunity scenarios below:

**Lower Overall Prior Immunity (overall 30%):**

- Ages 0-4: $R_1(t=0) = 0.0966$
- Ages 5-17: $R_2(t=0) = 0.1087$   
- Ages 18-49: $R_3(t=0) = 0.2173$
- Ages 50-64: $R_4(t=0) = 0.4967$
- Ages 65+: $R_5(t=0) = 0.5796$ 

**Higher Prior Overall Immunity (overall 35%):**

- Ages 0-4: $R_1(t=0) = 0.1127$
- Ages 5-17: $R_2(t=0) = 0.1268$   
- Ages 18-49: $R_3(t=0) = 0.2535$
- Ages 50-64: $R_4(t=0) = 0.5795$
- Ages 65+: $R_5(t=0) = 0.6762$ 

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2025-26 season.
The mean initial proportion of the population with any type of residual immunity across simulations was 32.5% $\pm$ 0.74%. 

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
**Natural immunity waning details:**
The rate at which natural immunity wanes is dependent upon age class according to [Kucharski et al. 2015, Fig.4](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1002082#pbio-1002082-g004):

- Ages 0-4: $\kappa_1= 1/(10/4.5*365)$
- Ages 5-17: $\kappa_2= 1/(10/4*365)$,  
- Ages 18-49: $\kappa_3= 1/(10/2*365)$,
- Ages 50-64: $\kappa_4= 1/(10/1.75*365)$,
- Ages 65+: $\kappa_5= 1/(10/1.5*365)$ 


**Vaccine-induced immunity waning details:**
Vaccine-induced immunity, $\epsilon$, wanes at a rate of 1/(6*30) days^-1^ ([Ferdinands et al. 2017](https://academic.oup.com/cid/article/64/5/544/2758477?login=false)).


## Details on Influenza Strain(s)
### Number of strains/subtypes included in model
The model only considers a single strain/subtype of influenza.

### Strain(s) specifications (immune escape, transmissibility)
N/A

### Are interactions between strains/subtypes implicitly modeled?
No

## Seasonality implementation
$R_0$ was calculated as $R_0=f(t)*(R_{0max}-R_{0min})+R_{0min}$ and $\beta$ was calculated as $\beta=R_0/(\rho(M)*D)$ where $\rho(M)$ is the dominant eigenvalue of the contact matrix between age groups, $M$, and $D$ is the duration of infectiousness. 
The start date for seasonal forcing for each simulation was randomly selected as a date between 2025-09-15 and 2025-10-15. A 50% reduction in transmission was applied to age classes 0-4 and 5-17 over the following dates to approximate school holidays:

- 2025-11-20 and 2025-11-24
- 2025-12-23 and 2025-12-31
- 2026-03-23 and 2026-04-01

The end date for seasonal forcing was randomly selected as a date between 2026-02-06 and 2026-04-07.

## Initial Conditions
Infectious seeds were distributed randomly, but proportionally to the population size of each age class in the state of California. 

**Weeks 1-16:**

- Ages 0-4: 0
- Ages 5-17: X∼U(100,500) 
- Ages 18-49: X∼U(700,1100) 
- Ages 50-64: X∼U(100,500) 
- Ages 65+: X∼U(100,500) 

Infectious seeding was matched across scenarios, e.g., `stochastic_run ==1` across scenarios A, B & C would have the same initialization of infectious seeding.

### Details on circulating strains at the start of the projection period
N/A

## Non-pharmaceutical interventions (NPIs)
N/A

## Age Group Variability
### No of age groups
Five age groups were included in the model following typical flu reporting: 0-4, 5-17, 18-49, 50-64, 65+.


### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
Age groups differ in their: proportion with prior immunity, vaccine effectiveness, hospitalization rates, hospital length of stay, and death rates. Age groups were considered to have different contact rates, informed by synthetic contact matrices from [Fumanelli et al. 2012](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1002673).


## State-level Variability
### State-stratification details (prior immunity, vaccine coverage)
Initial conditions for prior immunity and waning of prior immunity by age class are described in the **Model Assumptions** section above. Vaccine coverage was implemented by age class in the model following the vaccination coverage curves provided by the [Scenario Modeling Hub](https://raw.githubusercontent.com/midas-network/flu-scenario-modeling-hub_resources/main/Rd6_datasets/Age_Specific_Coverage_Flu_RD1_2025_26_Sc_A_B.csv) for the state of CA. 

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
The model assumes that VE against infection is 50% of that for VE against hospitalization for a given age class $i$, e.g. $VE_{infection,i}= 0.5*VE_{hospitalization, i}$.

### VE against mortality (by age, if relevant)
The model does not explicitly include VE against mortality, but does include VE against hospitalization, which is sampled as a uniform distribution with minimum and maximum values defined by the adjusted by age group rates from CDC Influenza Burden Estimates for the following exemplar seasons:

- **H3N2:** 0.64 (0-4 y/o), 0.39 (5-17 y/o), 0.21 (18-49 y/o), 0.20 (50-64 y/o), 0.11 (65+ y/o) [2017-2018 season] (https://www.cdc.gov/flu/vaccines-work/2017-2018.html) 
- **H1N1:** 0.34 (0-4 y/o), 0.38 (5-17 y/o), 0.34 (18-49 y/o), 0.40 (50-64 y/o), 0.39 (65+ y/o) [2019-2020 season] (https://www.cdc.gov/flu/vaccines-work/2019-2020.html)

Although H1N1 vs. H3N2 predominant season was not an explicit axis in this scenario round, we used these seasons as reference points the bound uncertainty in the hospitalization rates because of stark differences in outcomes for particular age groups, particularly 0-4 (0.34 vs. 0.64) and 65+ (0.11 vs. 0.39).

### VE against transmission (by age, if relevant)
The model assumes that VE against transmission is negligible. 

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
This model assumes "leaky" vaccination, i.e., vaccinated individuals may still be infected or hospitalized, but do so at lower rates than their un-vaccinated counterparts.

### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
Uncertainty is generated within a single scenario via:

**Parameter sampling:**

- incubation period, $\sigma$
- recovery rate, $\gamma$
- hospitalization rate
- vaccine effectiveness against infection
- vaccine effectiveness against hospitalization
- rate of loss of vaccine induced immunity, $\epsilon$

**Aleatory uncertainty:**
Aleatory uncertainty exists in the model via state transitions administered via the tau leap method. 

## Other Model Assumptions
N/A
