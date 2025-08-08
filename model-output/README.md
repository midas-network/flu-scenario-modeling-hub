# Data submission instructions

This page is intended to provide teams with all the information they
need to submit scenarios.  

All projections should be submitted directly to the [model-output/](./) 
folder. Data in this directory should be added to the repository
through a pull request. 

Due to file size limitation, the file can be submitted in a in a 
`.parquet` or `.gz.parquet`.


----

## Subdirectory

Each sub-directory within the [model-output/](./) directory has the
format:

    team-model
    
where 

- `team` is the abbreviated team name and 
- `model` is the  abbreviated name of your model. 

Both team and model should be less than 15 characters, and not include
hyphens nor spaces.

----

### Metadadata

Each submission team should have an associated metadata file. The file should
be submitted with the first projection in the 
[model-metadata/](../model-metadata/) folder, in a file named: 
`team-model.yaml`.

For more information on the metadata file format, please consult the associated
[README](../model-metadata/README.md)

---

## Date/Epiweek information

For week-ahead scenarios, we will use the specification of epidemiological
weeks (EWs) 
[defined by the US CDC](https://ndc.services.cdc.gov/wp-content/uploads/MMWR_Week_overview.pdf)
which run Sunday through Saturday.

There are standard software packages to convert from dates to epidemic weeks
and vice versa. E.g. 
[MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) 
for R and [pymmwr](https://pypi.org/project/pymmwr/) and 
[epiweeks](https://pypi.org/project/epiweeks/) for python.

---

## Model Results

Each model results file within the subdirectory should have the following 
name

    YYYY-MM-DD-team-model.parquet
    
where

- `YYYY` is the 4 digit year,
- `MM` is the 2 digit month,
- `DD` is the 2 digit day,
- `team` is the teamname, and
- `model` is the name of your model.

"parquet" files format from Apache is "is an open source, column-oriented data
file format designed for efficient data storage and retrieval". Please find more
information on the [parquet.apache.com](https://parquet.apache.org/) website.

The "arrow" library can be used to read/write the files in 
[Python](https://arrow.apache.org/docs/python/parquet.html) and 
[R](https://arrow.apache.org/docs/r/index.html).
Other tools are also accessible, for example 
[parquet-tools](https://github.com/hangxie/parquet-tools)

For example, in R:
```r
# To write "parquet" file format:
filename <- ”path/model-output/team-model/YYYY-MM-DD-team_model.parquet”
arrow::write_parquet(df, filename)
# with "gz compression"
filename <- ”path/model-output/team-model/YYYY-MM-DD-team_model.gz.parquet”
arrow::write_parquet(df, filename, compression = "gzip", compression_level = 9)

# To read "parquet" file format:
arrow::read_parquet(filename)
```

The date YYYY-MM-DD should correspond to the start date for scenarios
projection ("first date of simulated transmission/outcomes" as noted in the
scenario description on the main 
[README, Submission Information](https://github.com/midas-network/flu-scenario-modeling-hub/blob/main/README.md#submission-information)).

The `team` and `model` in this file must match the `team` and `model` in the 
directory this file is in. Both `team` and `model` should be less than 15 
characters, alpha-numeric and underscores only, with no spaces or hyphens.

If the size of the file is larger than 100MB, it should be submitted in a 
`.gz.parquet` format. 
If the 100MB limit is not solved by compression the submission file can also 
be partitioned. 


### Partitioning 

The submission files can be partitioned with the "arrow" library and should 
be partitioned by `origin_date` and `target`.

The basename template should match the previous standard (
`"YYYY-MM-DD-team-model.parquet"`) with the a date and the 
aggregation of the team and model abbreviation name. 

For example, in R:
```R
team_folder <- ”path/model-output/<team_model>/”

# Without compression
arrow::write_dataset(df, team_folder, partitioning = c("origin_date", "target"),
                     hive_style = FALSE,
                     basename_template = "YYYY-MM-DD-tteam_model{i}.parquet")

# With GZIP Compression
arrow::write_dataset(df, team_folder, partitioning = c("origin_date", "target"),
                     hive_style = FALSE, compression = "gzip", 
                     compression_level = 9,
                     basename_template = "YYYY-MM-DD-team_model{i}.gz.parquet")
```


For example, in Python:
```Py
import pyarrow.dataset as ds

team_folder <- ”path/model-output/<team_model>/”


# Without compression
ds.write_dataset(table, team_folder, partitioning=["origin_date", "target"],
                 format="parquet", partitioning_flavor=None, 
                 basename_template="YYYY-MM-DD-team_model{i}.parquet")

# Compression options
fs = ds.ParquetFileFormat().make_write_options(compression='gzip', 
                                               compression_level=9)
# With GZIP Compression
ds.write_dataset(table, team_folder, partitioning=["origin_date", "target"],
                 format="parquet", partitioning_flavor=None, file_options=fs,
                 basename_template="YYYY-MM-DD-team_model{i}.gz.parquet")
```

Please note that the `hive_style` or `partitioning_flavor` should be set to 
`FALSE` or `None`, so all the teams have the same output style. 

The submission file columns used for the partitioning (`origin_date` and 
`target`) should not be present in the `.parquet` file. 

---

## Model results file format

The output file must contain eleven columns (in any order):

- `origin_date`
- `scenario_id`
- `target`
- `horizon`
- `location`
- `age_group`
- `output_type` 
- `output_type_id` 
- `value`
- `run_grouping`
- `stochastic_run`

No additional columns are allowed.

Each row in the file is a specific type for a scenario for a location on
a particular date for a particular target. 

### Column format

|Column Name|Accepted Format|
|:---:|:---:|
| `origin_date`    | character, date (datetime not accepted)   |
| `scenario_id`    | character                                 |
| `target`         | character                                 |
| `horizon`        | numeric, integer                          |
| `location`       | character                                 |
| `age_group`      | character                                 |
| `output_type`    | character                                 | 
| `output_type_id` | numeric, character, logical (if all `NA`) | 
| `value`          | numeric                                   |
| `run_grouping`   | numeric, integer                          |
| `stochastic_run` | numeric, integer                          |


### `origin_date`

Values in the `origin_date` column must be a date in the format

    YYYY-MM-DD
    
The `origin_date` is the start date for scenarios (first date of 
simulated transmission/outcomes).
The "origin_date" and date in the filename should correspond.


### `scenario_id`

The standard scenario id should be used as given in in the scenario
description in the 
[main Readme](https://github.com/midas-network/flu-scenario-modeling-hub). 
Scenario IDs include a captitalized letter and date as YYYY-MM-DD, e.g.,
`A-2020-12-22`.


### `target`

The submission can contain multiple output type information: 
- Representative trajectories from the model simulations.
  We will call this format "sample" type output. For more information, please
  consult the [sample](./README.md#sample) section.
- A set of quantiles for all the tarquets.
  We will call this format "quantile" type output. For more information, 
  please consult the [quantile](./README.md#quantile) section. 
- A cumulative distribution function for the peak timing target. We will 
  call this format "cdf" output type. For more information, please consult 
  the [cdf](./README.md#cdf) section.

The requested targets are (for `"sample"` type output):
- weekly incident deaths (US level only)
- weekly incident hospitalizations 

Optional target:

- sample:
    - weekly incident emergency department visit
- quantile:
    - cumulative deaths (US level only)
    - cumulative incident hospitalizations
    - cumulative incident emergency department visit
    - weekly incident deaths (US level only)
    - weekly incident hospitalizations
    - weekly incident emergency department visit
    - peak size hospitalizations
- cdf:
    - weekly peak timing hospitalization

Values in the `target` column must be one of the following character strings:
- `"inc death"`  
- `"inc hosp"`
- `"inc ed visit"`
- `"cum death"`  
- `"cum hosp"`
- `"cum ed visit"`
- `"peak size hosp"`
- `"peak time hosp"`


#### inc death

This target is the incident (weekly) number of deaths predicted by the model
during the week that is N weeks after `origin_date`. 

A week-ahead scenario should represent the total number of new deaths on 
the dates they occurred, not on the date they were reported (from Sunday through 
Saturday, inclusive).

Predictions for this target will be evaluated compared to the number of new
deaths, as recorded by the National Center for Health Statistics (NCHS) as 
distributed by the
[FluView Interactive - Mortality CDC dashboard](https://gis.cdc.gov/grasp/fluview/mortality.html). 


#### inc hosp

This target is the incident (weekly) number of hospitalized cases predicted by
the model during the week that is N weeks after `origin_date`. 

A week-ahead scenario should represent the total number of new hospitalized
cases reported during a given epiweek (from Sunday through Saturday,
inclusive).

Predictions for this target will be evaluated compared to the number of new
hospitalized cases, as reported by the NHSN and available on 
[data.cdc](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data).


#### inc ed visit

This target is the incident (weekly) number of emergency department visit 
predicted by the model during the week that is N weeks after `origin_date`. 

A week-ahead scenario should represent the total number of new hospitalized
cases reported during a given epiweek (from Sunday through Saturday,
inclusive).

Predictions for this target will be evaluated compared to the number of new
emergency department visit, as reported by the NSSP and available on 
[data.cdc](https://data.cdc.gov/Public-Health-Surveillance/NSSP-Emergency-Department-Visit-Trajectories-by-St/rdmq-nq56/about_data).


#### cum death

This target is the cumulative number of deaths predicted by the model during 
the week that is N weeks after `origin_date` (since start of the simulation). 

A week-ahead scenario should represent the cumulative number of deaths
reported on the Saturday of a given epiweek.


#### cum hosp

This target is the cumulative number of incident (weekly) number of
hospitalized cases predicted by the model during the week that is N weeks
after `origin_date` (since start of the simulation). 

A week-ahead scenario should represent the cumulative number of hospitalized
cases reported on the Saturday of a given epiweek.


#### cum ed visit 

This target is the cumulative mumber of emergency visit department visit
predicted by the model during the week that is N weeks after `origin_date` 
(since start of the simulation). 

A week-ahead scenario should represent the cumulative number of emergency 
department visit reported on the Saturday of a given epiweek.


#### peak time hosp

This target is the cumulative probability of the incident hospitalization peak 
occurring before or during the week that is N weeks after `origin_date`. For instance 
"peak time hosp" on the 22nd epiweek of projection is the probability that 
hospitalizations peak within the first 22 weeks of the projection period. This 
cumulative probability will be 1 on the last week of the projection period. A 
probability of 1 in the first week of the projection period could mean either 
future projections are not expected to exceed a prior peak or projections expect 
the peak will occur in the first week.

Predictions for this target will be evaluated against the week of the peak number 
of hospitalized cases, as recorded by the NHSN hospitalized cases 
(derived from the influenza admissions variable).

#### peak size hosp

This target is the magnitude of the peak of weekly incident hospitalizations in 
the model, when considering the full projection period.

Further, we do not expect a full time series, the `horizon` column associated with 
this value should be set to `NA`.

Predictions for this target will be evaluated against the size of the peak number of 
weekly hospitalized cases, as recorded by the NHSN hospitalized cases  (derived from 
the influenza admissions variable).


### `horizon`


Values in the `horizon` column must be an integer (N) between 1 and last week 
horizon value representing the associated target value during the N weeks
after `origin_date`. The information is noted in the
scenario description on the main 
[README, Submission Information](https://github.com/midas-network/flu-scenario-modeling-hub)),
see "Simulation end date" information

For example, between 1 and 104 forpast  Round 17 ("**Simulation end date:** 
April 19, 2025 (104-week horizon)") and in the following example table,
the first row represent the number of incident death in the US, for the 1st 
epiweek (epiweek ending on 2023-04-22)after 2023-04-16 for the scenario 
A-2023-04-16. 

|origin_date|scenario_id|location|target|horizon|...|
|:---:|:---:|:---:|:---:|:---:|:---:|
|2023-04-16|A-2023-04-16|US|inc death|1|...|
||||||


### `location`

Values in the `location` column must be one of the "locations" in this
[FIPS numeric code file](../auxiliary-data/data-locations/locations.csv) which 
includes numeric FIPS codes for U.S. states, territories aswell as "US" for
national scenarios. 

Please note that when writing FIPS codes, they should be written in as a 
character string to preserve any leading zeroes.

For the round 1, only the location included in RSV-NET target data are 
expected:
`"US","06","08","09","13","24","26","27","35","36","41","47","49"`


### `age_group` 

Accepted values in the  `age_group` column are:

- `"0-4"`
- `"5-17"`
- `"18-49"`
- `"50-64"`
- `"65-130"`
- `"0-130"` (required)

The overall population `age_group` (`0-130`) is required. 

**For the `peak` targets, only the age-group `"0-130"` is required.**

### `output_type`

Values in the `output_type` column are either

- `"sample"` or 
- `"quantile"` (optional) or
- `"cdf"` (optional)

This value indicates whether that row corresponds to a "sample" scenario,
quantile scenario or cdf.

**Scenarios must include "sample" scenario for every
  scenario-location-target-horizon group.**

### `output_type_id`

#### `sample`

For the simulation samples format only. Value in the `output_type_id` 
column is `NA`

The id sample number is input via two columns:

- `run_grouping`: This column specifies any additional grouping if it controls 
   for some factor driving the variance between trajectories (e.g., underlying 
   parameters, baseline fit) that is shared across trajectories in different 
   scenarios. I.e., if using this grouping will reduce overall variance 
   compared to analyzing all trajectories as independent, this grouping should 
   be recorded by giving all relevant rows the same number. If no such 
   grouping exists, number each model run independently. 
- `stochastic_run` : a unique id to differentiate multiple stochastic runs. If 
   no stochasticity: the column will contain an unique value

Both columns should only contain integer number. 

The submission file is expected to have 100 simulation samples 
(or trajectories) for each "group". 

For example, if a round is required to have the trajectories grouped at least by 
`"age_group"` and `"horizon"`, so it is required that the combination of 
the `run_grouping` and `stochastic_run` columns contains at least an unique
identifier for each group containing all the possible value for `"age_group"` 
and `"horizon"`.

Fore more information and examples, please consult the 
[Sample Format Documentation page](https://scenariomodelinghub.org/documentation/sample_format.html).

For example:

|origin_date|scenario_id|location|target|horizon|age_group|output_type|output_type_id|run_grouping|stochastic_run|value|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|2024-04-28|A-2024-03-01|US|inc hosp|1|0-64|sample|NA|1|1||
|2024-04-28|A-2024-03-01|US|inc hosp|2|0-64|sample|NA|1|1||
|2024-04-28|A-2024-03-01|US|inc hosp|3|0-64|sample|NA|1|1||
||||||||||||
|2024-04-28|A-2024-03-01|US|inc hosp|1|0-64|sample|NA|2|1||
|2024-04-28|A-2024-03-01|US|inc hosp|2|0-64|sample|NA|2|1||
||||||||||||


#### `quantile` 

Values in the `quantile` column are quantiles in the format

    0.###

For quantile scenarios, this value indicates the quantile for the `value` in
this row. 

Teams should provide the following 23 quantiles:

``` 
0.010 0.025 0.050 0.100 0.150 0.200 0.250 0.300 0.350 0.400 0.450 0.500
0.550 0.600 0.650 0.700 0.750, 0.800 0.850 0.900 0.950 0.975 0.990 
```

For example:

|origin_date|scenario_id|location|target|horizon|age_group|output_type|output_type_id|run_grouping|stochastic_run|value|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|2024-04-28|A-2024-03-01|US|inc death|1|0-64|quantile|0.010|NA|NA||
|2024-04-28|A-2024-03-01|US|inc death|1|0-64|quantile|0.025|NA|NA||
||||||||||||


#### `cdf`

Values in the `output_type_id` column are the epiweek associated with cumulative 
probability of the incident hospitalization peak occurring before or during the 
week that is N weeks after `origin_date` in the format:

    EWYYYYWW
    

For instance `"EW202337"`` is the probability that hospitalizations peak within 
the epiweek 2023-37 or before.

Teams should provide the complete time series associated with the round, and the
`horizon` column should be set to `NA` value. The week 
information should be in 2 digits format, so if the epiweek is for example 2024-2, 
then it should be reported as `"EW202402"`. 

It can be calculated by applying:

-  `origin_date` +  7 * `N` - 1 (N being the number of
week ahead projection in the associated target, e.g `"1 wk ahead"`, 
`"2 wk ahead"` after the start of the projection), and transform
the output in epiweek format.

For example:
```
# If `origin_date` is "2023-09-03"

# Week 1 will be:
week1_date = as.Date("2023-09-03") + 7 * 1 - 1
epiweek1 = MMWRweek::MMWRweek(week1_date) 
epiweek1 

```

The output file with the cdf should follow this example (following round 1 2023-2024):
|origin_date|scenario_id|location|target|horizon|age_group|output_type|output_type_id|value|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|2023-09-03|A-2023-08-14|US|inc death|NA|0-130|cdf|EW202336||
|2023-09-03|A-2023-08-14|US|inc death|NA|0-130|cdf|EW202337||
||||||||||
|2023-09-03|A-2023-08-14|US|inc death|NA|0-130|cdf|EW202422||


### `value`

Values in the `value` column are non-negative numbers integer or with one
decimal place indicating the "sample" or "quantile" prediction for this row. 

For a "quantile" prediction, `value` is the inverse of the cumulative distribution
function (CDF) for the `target`,`horizon`, `location`, and `quantile` associated with 
that row.


#### Peak time hosp

For the `peak time hosp` target, the values in the `value` column are non-negative 
numbers between 0 and 1.  


---

## Scenario validation

To ensure proper data formatting, pull requests for new data or updates in
`model-output/` and `model-metadata/` are automatically validated.


### Pull request scenario validation

When a pull request is submitted, the data are automatically validated.
The intent for these tests are to validate the requirements above and
all checks are specifically enumerated on the
[SMH website](https://scenariomodelinghub.org/documentation/validation.html).

Please 
[let us know](https://github.com/midas-network/flu-scenario-modeling-hub/issues) if
the wiki is inaccurate.

### Workflow

When a pull request is submitted, the validation will be 
automatically triggered.

- If the pull request (PR) contains update abstract file(s):
    - These files are manually validated, the automatic validation
    will only returns a message indicating it did not run any
    validation. 

- If the PR contains model output and/or model metadata submission file(s). 
The validation automatically runs and output a message.

    - The validation has 3 possible output:
        - "Error" (red cross): the validation has failled and returned a message 
        indicating the error(s). The error(s) should be fixed to have the PR 
        accepted
        - "Warning" (red !): the PR will fail but it can be accepted. It is 
        necessary for the submitting team to validate if the warning(s) is 
        expected or not before merging the PR. If all warning are expected and
        accepted, the PR will be merged without needed modification on those
        warning. 
        - "Success" (green check): the validation did not found any issue and 
        returns a message indicating that the validation is a success

If any issues or questions on a PR, please feel free to send them in the PR via
comments.

#### Run checks locally

To run these checks locally rather than waiting for the results from a pull
request, the package 
[SMHvalidation](https://github.com/midas-network/SMHvalidation) contains 
multiple documentation and vignettes. 

