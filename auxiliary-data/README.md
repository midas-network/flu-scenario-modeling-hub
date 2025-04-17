# Auxiliary Data

This folder is used to store additional information and data relevant to the 
Flu modeling efforts. 

The data are organized in multiple sections:

- [Reports](./README.md#reports)
- [Locations and Census Data](./README.md#location-and-census-data)
- [Target Data Archive](./README.md#target-data-archive)
- [Rounds](./README.md#rounds)
- [Additional Resources](./README.md#additional-resources)
    - [MIDAS Network Curated Archive](./README.md#midas-network-curated-archive)
    
If there any issues, or questions, please feel free to 
[open an issue](https://github.com/midas-network/flu-scenario-modeling-hub/issues).
If you want to contribute to the list of resources, please free to 
[open an issue](https://github.com/midas-network/flu-scenario-modeling-hub/issues) or
[open a Pull Request](https://github.com/midas-network/flu-scenario-modeling-hub/pulls) 
containing the information to add. 

## Reports

The [reports](./reports/) folder contains reports from previous 
Scenario Modeling Hub rounds, starting round 1 2025-2026. At the time they were 
produced, some of these reports were intended to be shared only with certain 
stakeholders and have disclaimers to that effect. All reports have since 
become publicly available.

Each report contains an executive summary with key messages and results, and
analyses of ensemble and individual projections. Results at national and 
state level are available for all targets. 

For round 1 to round 1 2024-2025 (round 5), the report are available in the 
FLU Scenario Modeling Hub Archive Repository, folder 
[code/reports](https://github.com/midas-network/flu-scenario-modeling-hub_archive/tree/main/reports).

## Location and Census Data

The folder [data-locations/](./data-locations/) contains one `csv` files:

- [locations.csv](./data-locations/locations.csv) containing
  the state and national  names, 2 letter abbreviation and fips code as used 
  in the hub. The file also contains the population size. 

## Target Data Archive

The [target-data_archive](./target-data_archive) folder contains archive of the
target-data `time-series` data. 
The data are automatically updated on Monday, and the past version will be 
automatically moved to this folder, with the date append to the file name.

## Rounds

The [rounds](./rounds/) folder contains the round information starting round 
1 2025-2026 (round 6) in a markdown format with a folder names `roundX_viz` with X being 
the round number, containing associated visualization (for example, scenario 
table in a PNG format).

For previous round, please consult the
[Flu Scenario Modeling Hub - Archive](https://github.com/midas-network/flu-scenario-modeling-hub_archive/tree/main/previous-rounds) 
GitHub Repository. 

## Additional Resources

### MIDAS Network Curated Archive

The MIDAS Network has created a 
[MIDAS Curated Archive of Global Public Health Data](https://midasnetwork.us/midas-archive) 
available via the [MIDAS Catalog](https://midasnetwork.us/catalog) for 
infectious disease modeling research including data and associated rich 
metadata.

To search the MIDAS Curated Archive of Global Public Health Data in the 
Catalog, please select:

- Collection: `"Curated Archive of Global Public Health Data"`
- Topic:
    - Hospitalization: use the topic `"hospital stay dataset"` under 
    "case counts"
    - ED visits: use the topic `"emergency department visit dataset"` under 
    "case counts"
    - Deaths: use the topic `"mortality data"` under "case counts"
    - Cases: use the topic `"case counts"`
    - Vaccination: use the topic `"vaccination administration census"` under
    "control strategy census"
    - Tests and positivity: use the topic `"Diagnostic Tests"` under 
    "case counts"
    - Wastewater: use the topic `"Wastewater"`
    - Variants: use the topic `"variant cases"` under "case counts"


