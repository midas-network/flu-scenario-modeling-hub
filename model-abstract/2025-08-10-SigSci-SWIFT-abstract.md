
# Summary of Results

Across the aggregate US and 47 states (DC/PR excluded; NV/ID/SD censored), incident influenza hospitalizations generally rise through autumn, crest in winter, and decline through spring. Most states peak between late December and early February, while the US aggregate peaks in early to mid February. Scenario-to-scenario differences (A, B, C) are present but modest relative to cross-state heterogeneity due to the mild predicted season. Peak heights vary by over an order of magnitude across geographies. Wave breadth—summarized by the contiguous weeks at ≥50% of each state’s peak—most often falls in the ~8–14 week range, with a minority exhibiting shorter (<6 weeks) or more prolonged (>15 weeks) waves. Uncertainty bands are unrealistically narrow early in the season, widen around each crest, and contract on the downslope, consistent with paired-\(S_0\) stochastic trajectories and observation noise. For the aggregate US, our median predicted peak under scenario A is around 12,000 hospitalizations. Under scenario B, it is 17,000, and under scenario C, it is 26,000. Our most extreme weekly hospitalization across all scenarios and trajectories was around 135,000 hospitalizations.

# General Model Description

We produce weekly influenza hospitalization projections using a stochastic SEIR framework at the geography level (United States and 47 states - DC and PR excluded; ID, NV, and SD censored for implausible projections). The transmission model tracks all ages in a single set of compartments and derives incident hospitalizations from a cumulative hazard process:

- **Compartments:** \(S, E, I, R\) and an auxiliary cumulative state \(A\).  
- **Incident hospitalizations** at week \(t\): \(\Delta A_t = \text{hosp}_{\text{eff, t}}\,I_t\). There is no explicit \(H\) compartment; \(A\) accumulates the flow from \(I\) to hospitalization.
- **Seasonality (dual-harmonic forcing):** we implicitly model dual strains by implementing a dual-harmonic seasonal forcing term in the transmission rate.  
  \[
  \beta(t)=b_0 + a_1 \cos\!\Big(\frac{2\pi (t-\text{peak})}{52}\Big)
                 + a_2 \cos\!\Big(\frac{4\pi (t-\text{peak2})}{52}\Big).
  \]
- **Vaccination:** \(S \to R\) via a weekly vaccination hazard multiplied by a location-specific, age-weighted vaccine efficacy against infection, \(VE_{\text{inf, t}}\).
- **Severity reduction:** the per-week hospitalization hazard \(\text{hosp}_{\text{eff, t}}\) is scaled by an age-weighted \(VE_{\text{hosp, t}}\): \(\text{hosp}_{\text{eff, t}}=\text{hosp}_0\,[1-VE_{\text{hosp, t}}]\). The average \(VE_{\text{hosp, t}}\) across age groups was scaled to remain at 50% despite the age-weighting.
- **Fixed progression rates:** latent \(=7/3\) per week; recovery \(=1\) per week.

Geography-specific parameters \((b_0, a_1, a_2, \text{peak}, \text{peak2}, \text{hosp}_0, N, I_0, E_0)\) are obtained from a calibration table and held fixed across scenarios within a geography (see model calibration below).

#### Initial susceptibility (\(S_0\)) and pairing across scenarios ####

For each geography we draw \(S_0\) from a precomputed set of 500 paired \(S_0\) trajectories. The same \(S_0\) draw (i.e., the same `run_grouping`) is reused across all scenarios for that geography, as required by the Scenario Modeling Hub format. 

To estimate paired \(S_0\), we anchor the central \(S_0\) (median) for each geography to last season's inferred attack rate (converting hospitalizations to infections with age-weighted infection-hospitalization ratios) and then apply cross-immunity and off-season waning, so the prior is centered on that value. The dispersion (\(\kappa\)) comes from multi-season variability in historical \(S_0\). We did not use any data beyond Saturday, Aug 9, 2025 for this estimation.

#### Stochasticity ####

We apply week-to-week lognormal noise to \(\beta(t)\) and negative-binomial observation noise to weekly incident hospitalizations. Stochastic samples are reported with `stochastic_run = 1` while pairing of \(S_0\) across scenarios is carried by `run_grouping` (location × \(S_0\) replicate).

#### Scenarios and timing ####

We simulate 44 weeks starting on **origin_date = 2025-08-10** (Sunday) and report horizons **1–43** (we drop the first simulated index in post-processing per hub convention). Scenario identifiers follow the hub anchor format: **A-2025-07-29**, **B-2025-07-29**, **C-2025-07-29**. Scenario differences enter through the coverage/uptake trajectories (and associated \(VE\) schedules) supplied by the hub.

We submit **all-age weekly incident hospitalizations** (`inc hosp`) and the corresponding \(S_0\) tag per (location × \(S_0\) replicate). We are not submitting age-stratified targets or deaths for this round, but we could supply them at a later date if desired.

# Explanation of Observed Dynamics Given Model Assumptions

The combination of (i) seasonal forcing with two peaks, (ii) time-varying vaccination that reduces both susceptibility and severity, and (iii) geography-specific transmissibility and hospitalization hazard produces diverse early-season ramps and peak timings.

#### Peak Height #### 

Across scenarios A-C, higher baseline transmissibility, *b0*, is associated with higher peaks, while larger *hosp0* (baseline hospitalization hazard) dampens the peak. The second harmonic (*a2*) shows a negative association with peak size, consistent with energy being distributed across two seasonal lobes instead of a single sharp crest.  Associations with *S0*<sub>median</sub> appear negative in simple bivariate plots, which likely reflects co-adaptation among fitted parameters (e.g., states with larger *S0* also tending to have lower *b0* or higher *hosp0* after calibration).

#### Peak Timing ####

Timing is aligned with the phase parameter *peak* (later seasonal peak ⇒ later epidemic crest). We also see that larger *hosp0* shifts peaks earlier, whereas higher baseline transmissibility (*b0*) is linked to later peaks in the bivariate view — again likely reflecting trade-offs with the phase terms in the fitted seasonal forcing.

#### Curve elongation ####

Wider, more prolonged waves are associated with larger *a2* (a stronger second harmonic broadens the seasonal envelope) and slightly higher *S0*<sub>median</sub> (more susceptibles sustain transmission for longer). Higher *hosp0* shortens waves. The primary harmonic *a1* tends to narrow the wave (more concentrated forcing around the main crest).

#### Caveats #### 

These relationships are simple bivariate summaries; parameters were estimated jointly, so apparent correlations may reflect compensating trade-offs. They are useful for intuition (which knobs push height, timing, or duration) but should not be interpreted independently.


# Model Calibration

We calibrated state‐specific transmission and severity parameters using an augmented historical hospitalization dataset from our prior work (details and data construction in [medRxiv: 10.1101/2024.07.31.24311314](https://www.medrxiv.org/content/10.1101/2024.07.31.24311314v1)). From that resource, we selected four "baseline"" seasons that followed previously severe seasons. To place those historical signals on the current NHSN reporting scale, we multiplied the data by a factor proportional to "current NHSN estimates"/"before NHSN data estimates." We excluded years affected by the pandemic.

For each geography, we estimated the seasonal transmission parameters — baseline transmission \(b_0\), first and second harmonic amplitudes \(a_1, a_2\), and peak locations \(\text{peak}, \text{peak}_2\) — as well as the hospitalization flow rate \(\text{hosp}_0\). Disease durations were fixed at latent \(= 7/3\) per week and recovery \(= 1.0\) per week. For calibration, initial susceptibility \(S_0\) was *not* fitted: we fixed it to the geography-specific median from our paired \(S_0\) draws. Vaccination drivers used during calibration were scenario-A hazard schedules with age-weighted efficacy reductions (for infection and severity) aggregated to the geography level.

To avoid ad-hoc seeding, we derived initial \(E_0\) and \(I_0\) from early-season baselines (epiweeks 1–6) using a \(\text{hosp}_0\) prior and then capped them by population. We minimized RMSE between observed and model-predicted weekly incident hospitalizations with simple regularization on the second harmonic. A bounded L-BFGS-B optimizer with a small multi-start grid was used per geography. We logged fit diagnostics (RMSE, correlation) and retained the best-fit parameter vector along with a reproducible record of seeds and driver series.


# Model Assumptions

#### Immunity Assumptions

- **Number/type of immune classes considered:** One fully susceptible class \(S\) and one fully immune class \(R\) are modeled at the all-age level per geography.
- **Initial proportion immune / susceptible:** Initial states \((S_0, E_0, I_0, R_0)\) are geography-specific. \(S_0\) varies by geography and is sampled from paired draws; each submitted trajectory includes a corresponding \(S_0\) tag row (horizon = NA).
- **Waning immunity within season:** No explicit within-season waning is modeled. Time-varying vaccination moves individuals from \(S\) to \(R\) via an effective vaccination hazard; vaccine failure is implicit in the age-weighted \(VE_{\text{inf}}(t)\). Waning immunity is considered across seasons in estimation of paired \(S_0\)s

#### Details on Influenza Strain(s)

- **Number of strains/subtypes:** Single explicitly modeled strain. The dual-harmonic seasonality captures early/late peaks that can emerge under mixed-subtype seasons, so dual strains are implicitly modeled.
- **Immune escape / transmissibility:** Captured implicitly via calibrated \(\beta(t)\) parameters; no explicit cross-immunity terms.
- **Interactions between strains:** Not modeled.

#### Seasonality Implementation

Dual-harmonic cosine seasonal forcing with two calibrated phase parameters (\(\text{peak}, \text{peak2}\)), each with different amplitudes (*a1* and *a2*), per geography.

#### Initial Conditions

Geography-specific seeds \(E_0\) and \(I_0\) are taken from the calibration table; \(R_0\) follows from \(N - S_0 - E_0 - I_0\). Simulations start on **2025-08-10**. See Initial susceptibility (\(S_0)\) section above.

#### Non-pharmaceutical Interventions (NPIs)

None modeled.

#### Age Group Variability

We submit **all-age** targets only. Internally, vaccination and severity reduction are **age-weighted** using geography-specific population shares to form \(VE_{\text{inf, t}}\) and \(VE_{\text{hosp, t}}\). The ODE itself is not age-stratified, and we do not apply post hoc age multipliers to hospitalizations (to produce age-group estimates) for this submission.

#### State-level Variability

All key parameters and initial conditions are calibrated per geography; vaccination hazard and VE schedules are geography- and scenario-specific based on hub-provided inputs. \(S_0\) draws are geography-specific and paired across scenarios.

#### Vaccine Efficacy

- **Against infection:** incorporated via age-weighted \(VE_{\text{inf, t}}\) multiplying the vaccination hazard \(S \to R\).
- **Against hospitalization (severity):** incorporated via age-weighted \(VE_{\text{hosp, t}}\) as a multiplicative reduction of \(VE_{\text{eff, t}}\).

#### Other Model Assumptions

- No explicit hospitalization compartment; incident hospitalizations are \(\Delta A_t\).
- Week-to-week lognormal noise on \(\beta(t)\) and negative-binomial observation noise on \(\Delta A_t\); submissions use the stochastic series with `stochastic_run = 1`.
- Submission formatting follows SMH guidance: horizons 1–43 relative to **2025-08-10**; `run_grouping` = location × \(S_0\) replicate (paired across scenarios); include a single `S0` tag row per location × \(S_0\) replicate.
- DC and PR are excluded; NV, ID, and SD were censored for implausible output.
