# Monitoring Design and Initial Threshold Rationale

## Purpose

The monitoring layer is designed to make each Google Play ingestion run easier to operate and review. It summarizes the latest run, checks database integrity, compares each app with its own recent behavior, and produces an automated health report.

## Reference data

The initial behavior baselines use the three most recent prior completed runs with the same 10 apps and the same 1,200-review target:

1. Phase 2 Day 3 controlled repeated run
2. Cadence Run A
3. Run B first-collection baseline

The initial empty-database load is excluded because its 0% duplicate rate is not representative of recurring ingestion. The very short Day 2 follow-up is also outside the three most recent reference runs.

## App-specific warning thresholds

For a metric with reference values $x_1, x_2, x_3$:

- Baseline = median of the reference values
- MAD = median absolute deviation from the baseline

The monitor applies the following initial rules:

| Signal | Warning rule |
|---|---|
| New inserts | Current value is below `median − max(3×MAD, 50% of median, 25 records)` |
| Duplicate rate | Current rate is above `median + max(3×MAD, 0.10)` |
| App runtime | Current runtime is above `median + max(3×MAD, 1 second)` |
| Quality flags | Absolute change in flags per fetched record is above `max(3×MAD, 0.10)` |

The minimum margins reduce unstable alerts while only three reference runs are available. Every threshold is saved in `monitoring_app_thresholds.csv` so the logic is reviewable.

## Failing rules

A run is classified as `failing` when any of the following occurs:

- the ingestion run does not complete
- an app collection returns an error or no records
- the database archive is corrupted or cannot be loaded
- fetched, inserted, and duplicate totals do not reconcile
- database row growth does not match new inserts
- raw and cleaned review counts do not match
- duplicate review identities are present
- orphan quality flags or foreign-key violations are present
- another critical validation check fails

## Warning interpretation

A warning is an operational review signal, not proof that the pipeline failed. For the current Run B follow-up, all 22 validation checks pass and there are no collection errors. TikTok and YouTube are marked warning only because their duplicate rates increased beyond their first app-specific thresholds.

The thresholds should be recalibrated after more routine once-daily runs are available. The current rules are transparent starting points grounded in the completed repeated-run and cadence evidence.
