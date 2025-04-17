# Flu Scenario Modeling Hub

<a href="https://fluscenariomodelinghub.org/"><img src= "https://github.com/midas-network/flu-scenario-modeling-hub/blob/main/auxiliary-data/img/logo.png" alt="drawing" width="300"/></a>

Last updated: 2025-04-17.

## Previous Round Scenarios and Results:

<https://fluscenariomodelinghub.org/viz.html>

Previous rounds (round 1 to round 1 of 2024-2025 (round 5)) are available in the 
[Flu Scenario Modeling Hub - Archive](https://github.com/midas-network/flu-scenario-modeling-hub_archive) 
GitHub Repository


## Rationale

Even the best models of infectious disease transmission struggle to give 
accurate forecasts at time scales greater than 3-4 weeks due to unpredictable 
drivers like changing policy environments, behavior change, development of new 
control measures, and stochastic events. However, policy decisions around the 
course of infectious diseases, particularly emerging and seasonal infections, 
often require projections in the time frame of months. The goal of long-term 
projections is to compare outbreak trajectories under different scenarios, as 
opposed to offering a specific, unconditional estimate of what “will” happen. 
As such, long-term projections can guide longer-term decision-making while 
short-term forecasts are more useful for situational awareness and guiding 
immediate response.

We have specified a set of scenarios and target outcomes to allow alignment of 
model projections for collective insights. Scenarios have been designed in 
consultation with academic modeling teams and government agencies (e.g., CDC).

This repository follows the guidelines and standards outlined by the 
[hubverse](https://hubverse.io), which provides a set of data formats
and open source tools for modeling hubs.

## How to participate

The Flu Scenario Modeling Hub is open to any team willing to provide projections
at the right temporal and spatial scales, with minimal gatekeeping. We only 
require that participating teams share point estimates and uncertainty bounds, 
along with a short model description and answers to a list of key questions 
about design. A major output of the projection hub is ensemble estimates of 
epidemic outcomes (e.g., infection, hospitalizations, and deaths), for different
time points, intervention scenarios, and US jurisdictions.

Those interested to participate, please read the README file and email
us at
[scenariohub\@midasnetwork.us](mailto:scenariohub@midasnetwork.us).

Model projections should be submitted via pull request to the
data-processed folder of this GitHub repository. Technical instructions
for submission and required file formats can be found
[here](./model-output/README.md).


## Future Round 

Future round information will be available in this section (TBA).


## Submitting model projections

Groups interested in participating can submit model projections for each
scenario in a PARQUET file formatted according to our specifications,
and a metadata file with a description of model information. See
[here](./model-output/README.md)
for technical submission requirements.

## Target data

The [target-data/](./target-data) folder contains the target data
in a hubverse compliant 
[time-series format](https://hubverse.io/en/latest/user-guide/target-data.html).

The data are automatically updated on Monday morning. The code to generate the
data is available in the [src](./src/) folder.
The past version of the `time-series` files are stored in the 
[auxiliary-data/target-data_archive](./auxiliary-data/target-data_archive/) 
folder, with the date the data was archived append to the filename.

### Hospitalization

Weekly Hospital Respiratory Data (HRD) Metrics by Jurisdiction from
the [National Healthcare Safety Network (NHSN)](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data) will be used for incidence hospitalization
target. The data are weekly. 

## Auxiliary Data

The repository stores and updates additional data relevant to the Flu 
modeling efforts in the [auxiliary-data/](./auxiliary-data/) folder:
  
- Reports: Reports from Flu Scenario Modeling Hub rounds results. Each 
  report contains an executive summary with key messages and results, and 
  analyses of ensemble and individual projections. 

- Population and census data: National and State level name and fips code as 
  used in the Hub and associated population size.

- Rounds: Information on ongoing round and previous round available in the 
  repository

For more information, please consult the associated 
[README file](./auxiliary-data/README.md).


## Ensemble model

We aim to combine model projections into an ensemble.

## Data license and reuse

We are grateful to the teams who have generated these scenarios. The
groups have made their public data available under different terms and
licenses. You will find the licenses (when provided) within the
model-specific metadata files in the [model-metadata](./model-metadata/)
directory. Please consult these licenses before using these data to
ensure that you follow the terms under which these data were released.

All source code that is specific to the overall project is available
under an open-source [MIT license](https://opensource.org/licenses/MIT).
We note that this license does NOT cover model code from the various
teams or model scenario data (available under specified licenses as
described above).

## Computational power

Those teams interested in accessing additional computational power
should contact Katriona Shea at
[k-shea\@psu.edu](mailto:k-shea@psu.edu).

Additional resources might be available from the 
[MIDAS Coordination Center](https://midasnetwork.us/), 
please contact [questions\@midasnetwork.us](mailto:questions@midasnetwork.us) 
for information.

## Funding

Scenario modeling groups are supported through grants to the contributing 
investigators.

The Scenario Modeling Hub site is supported by the MIDAS Coordination Center, 
NIGMS Grant U24GM132013 (2019-2024) and R24GM153920 (2024-2029) to the
University of Pittsburgh.

## The Flu Scenario Modeling Hub Coordination Team

 - Shaun Truelove, Johns Hopkins University
 - Cécile Viboud, NIH Fogarty
 - Justin Lessler, University of North Carolina
 - Sara Loo, Johns Hopkins University
 - Lucie Contamin, University of Pittsburgh
 - Emily Howerton, Penn State University
 - Claire Smith, Johns Hopkins University
 - Harry Hochheiser, University of Pittsburgh
 - Katriona Shea, Penn State University
 - Michael Runge, USGS
 - Erica Carcelen, John Hopkins University
 - Sung-mok Jung, University of North Carolina
 - Jessi Espino, University of Pittsburgh
 - John Levander, University of Pittsburgh
 - Samantha Bents, NIH Fogarty
 - Katie Yan, Penn State University
 
### Past member

-   Wilbert Van Panhuis, University of Pittsburgh
-   Jessica Kerr, University of Pittsburgh
-   Luke Mullany, Johns Hopkins University
-   Kaitlin Lovett, John Hopkins University
-   Michelle Qin, Harvard University
-   Tiffany Bogich, Penn State University
-   Rebecca Borchering, Penn State University
