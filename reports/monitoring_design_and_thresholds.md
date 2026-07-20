# Monitoring Logic, Threshold Calibration, and Initial-Rule Rationale

## Baseline status

The current behavior baselines use the three most recent prior completed runs with the same 10 apps and 1,200-review target. This is a reasonable starting point, but the history is still small. All thresholds are therefore labeled **initial** and are not final production rules.

## Status model

Status priority is `failing` > `warning` > `healthy`.

- Hard failures produce `failing`: incomplete/failed collection, app collection error or zero records, database missing/corrupt/unloadable, failed critical validation, or missing/corrupt required core output.
- Warnings produce `warning` only when no hard failure exists: partial fetch without an explicit error, unusual new-insert drop, high duplicate rate, abnormal runtime, unexpected quality-flag movement, or missing supporting diagnostic output.
- Informational observations do not change status: normal within-threshold behavior, correctly skipped duplicates with reconciled totals, and the current small-baseline reminder.

## Initial thresholds

For each metric, baseline is the median and variability is the median absolute deviation (MAD) of the three prior comparable runs.

| Signal | Initial warning rule |
|---|---|
| New inserts | `current < median - max(3*MAD, 50% of median, 25 records)` |
| Duplicate rate | `current > median + max(3*MAD, 0.10)` |
| App runtime | `current > median + max(3*MAD, 1 second)` |
| Run runtime | `current > median + max(3*MAD, 15 seconds)` |
| Quality-flag rate | `absolute change > max(3*MAD, 0.10 flags/fetched record)` |

## Calibration evidence

Three completed runs were replayed with rolling prior-only reference windows. A sensitive comparison profile marked 3/3 runs warning and 7/30 app evaluations warning. The initial profile marked 1/3 runs warning and 2/30 app evaluations warning. A loose profile marked 0/3 runs and 0/30 apps warning, including removal of the useful TikTok and YouTube Run B follow-up signals.

The initial profile is retained as reasonable and provisional. Ten controlled synthetic scenarios also confirmed that hard failures override warnings and that informational observations remain healthy. These scenarios are not presented as real collections.

## Recalibration rule

Keep the current profile until additional routine fixed-scope runs are available. Recalculate the rolling baselines and review warning persistence before changing margins. Do not add automatic intervention or a complicated alerting system yet.
