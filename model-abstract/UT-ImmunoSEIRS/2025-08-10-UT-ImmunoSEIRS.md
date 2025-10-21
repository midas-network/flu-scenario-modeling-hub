# Summary of Results
The results show the development of a flu wave whose timing and magnitude is different depending on the location. In all projections, assumptions considered in scenario C (no vaccination coverage) caused to the highest level of hospitalizations. Scenario A (Business usual vaccination coverage) was the one that caused least hospitalizations at the national level and all states. Furthermore, we observed that under a scenario with a combination of high IHR and transmission rate, the hospitalizations peaked early and higher in number compared to a combination of low IHR and transmission rate when compared to the baseline parameters which were fitted based on calibration period of 2024-25 Influenza season. Additionally, the immunity assumed at the start of projections and its dynamics varying over the period does have the implicit impact. 


# General Model Description
Our age-structured SEIRS (Susceptible-Exposed-Infectious-Recovered-Susceptible) model simulates influenza transmission across six age groups (0-4, 5-11, 12-17, 18-49, 50-64, and 65+). Infected individuals are hospitalized based on age-specific infection hospitalizations rates. Seasonality is modeled using state-specific absolute humidity data from NOAA, age-specific contact patterns by setting, and national school and holiday calendars. A central feature of the model is its treatment of population immunity. Unlike traditional compartmental models, which assign individuals to discrete immune states, we use non-dimensional state variables to represent immunity continuously across the population. These variables track protection against infection and hospitalization, separately capturing immunity derived from vaccination and from prior infection. They evolve over time to reflect the accumulation and waning of protection, informed by published estimates of vaccine uptake, effectiveness and waning rates. The model accounts for both intraseasonal immunity—built up through new infections and vaccinations—and interseasonal immunity, which is estimated at the start of each season based on prior data and wanes over time. Because both the 2023-2024 and 2024–2025 influenza seasons were dominated by A(H1N1), though in 2024-25 season H3N2 proportion is similar to that of H1N1, we attribute both forms of immunity to a single subtype. Vaccine effectiveness (VE) against hospitalization was based on CDC estimates for the 2024–2025 season for the fitting period, while for projection it was as per hub guidelines to 50%. We included VE against infection as per hub reference to around 20%.
This model was previously developed and applied to project the 2023–2024 influenza season, with projections aligning closely with observed hospitalization data.


# Explanation of observed dynamics given model assumptions
The results can be explained by the higher baseline protection that previous infections offer in comparison to the protection offered by vaccines. In addition, immunity provided by vaccines wanes significantly faster than immunity gained through natural infections. Higher transmission rate gives early peak. 

# Model calibration
We calibrated the model separately for the United States and each state by fitting parameters to the seven-day moving average of reported influenza hospitalizations from October 8, 2024 to mid July, 2025. The fitted parameters included the transmission rate, seasonality amplitude, initial age-specific compartment sizes, age-specific infection hospitalization rates (IHR), in-hospital mortality rates, and initial immunity levels against infection and hospitalization. We used Python’s scipy.optimize.curve_fit function with the Levenberg–Marquardt algorithm to minimize the sum of squared errors between simulated and observed hospitalizations.
Initial values for immunity and IHR were treated as tuning parameters—set using expert judgment and data on reported cases and hospitalizations—rather than directly estimated, as they are not separately identifiable from the transmission rate. With these fixed, we fit the remaining parameters to hospitalization data, constrained by plausible ranges. Model parameters were iteratively refined until cumulative hospitalizations matched observed totals within 2% for each age group and the epidemic curves exhibited realistic seasonality and gradual changes in immunity.


# Model Assumptions
## Immunity assumptions
### Number/type of immune classes considered
The model tracks the population-immunity levels in a continuous way. We consider state variables corresponding to immunity gained from infection and vaccination.

### Initial proportion of population with residual immunity from previous infections and previous seasonal vaccinations at the start of the 2025-26 season.
According to the scenario assumptions, we consider that 30% have prior immunity. We calculate this average across age groups by considering that the most susceptible age groups have higher immunity than the less susceptible ones.  

### How is variability in this parameter engineered, if any?
NA.

### Waning immunity throughout the season (yes, no, differs for vaccination and natural infection)
We consider that the half-life time of immune waning is 8 months following natural infection and 3 after vaccination.

## Details on Influenza Strain(s)
### Number of strains/subtypes included in model
One

### Strain(s) specifications (immune escape, transmissibility)
The model describes that strain composition in each season generates its immunity independently. We assume a baseline transmission rate of 0.54 estimated for the baseline 2024-25 season. The transmission rate is then updated according to the specified effective reproduction number for the following season.

### Are interactions between strains/subtypes implicitly modeled?
Strain-strain interactions are not explicitly captured. Instead, the model captures each season's strain composition as a separate variant with a distinct immunity. In this analysis, and we considered same immunity as 24-25 for baseline projection. The epidemics of the following year are impacted by the remaining immunity, the prescribed effective reproduction number, seasonality effects and the IHR.

## Seasonality implementation
Yes. We incorporated seasonality by means of specific humidity specific to national and state levels. Additionally, school and work calendar along with contact matrices cater to human forced phenomenon.

## Initial Conditions
### Details on circulating strains at the start of the projection period
Current observation of H1N1 in 2025-2026 flu season

## Non-pharmaceutical interventions (NPIs)
We don't consider any NPIs.

## Age Group Variability
### No of age groups
Six.

### Age-stratification differences (susceptibility, vaccine effectiveness, waning)
We consider that age groups determine the chances of developing severe disease against infection. They also determine initial levels of immunity from infection and vaccination.

## State-level Variability
### State-stratification details (prior immunity, vaccine coverage)
Each state calibrated their own prior immunity, with their own previous vaccine acquired immunity.

## Vaccine Effectiveness
### VE against infection (by age, if relevant)
20% in all the scenarios. 50% against hospitalization which gives 37% against hospitalization given infection.

### VE against mortality (by age, if relevant)
N/A

### VE against transmission (by age, if relevant)
N/A

### Is the vaccine modeled a leaky or all-of-nothing (if relevant)
Leaky

### Summarize how uncertainty is generated within a single scenario. 1. Is there resampling of model parameters, and if so which parameters? 2. Is there additional stochasticity in the model, beyond parameter sampling?
Weekly Influenza-Like Illness (ILI) data from week 40 to April of each season were used to estimate the effective reproduction number (𝑅ₜ) using the estimate_R_cori() function from the EpiEstim framework, which applies a Bayesian renewal model. A gamma-distributed serial interval with mean 2.6 days and SD 1.5 days was assumed. For each influenza season, the median, mean, and maximum 𝑅ₜ values were computed. To scale 𝑅ₜ to a transmission rate (β), β for each season was derived relative to the 2024–25 season using the ratio of seasonal maximum 𝑅ₜ values. Similarly, the infection-hospitalization rate (IHR) for each season was estimated as the ratio of hospitalizations to symptomatic cases and scaled using the calibrated 2024–25 IHR as reference. Correlation analyses between IHR and β (2010–11 to 2023–24, excluding  2020–23 seasons) revealed no significant association. Finally, both β and IHR distributions were modeled using Beta distributions via the Python Fitter package, and 300 random samples were drawn from each fitted distribution for further analyses. No other stochasticity parameter. 

## Other Model Assumptions
N/A
