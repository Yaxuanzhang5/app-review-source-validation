# Monitoring Status and Operational Response Guide

## Status priority

`failing` overrides `warning`, and `warning` overrides `healthy`. Informational observations do not change status.

## Healthy

The run completed, required outputs are present, critical validations passed, and monitored behavior stayed within the current initial thresholds.

**Action:** Record the run, keep the normal schedule, and review it in the routine monitoring report. No immediate intervention is required.

## Warning

The run completed and remains usable, but one or more behavior or non-critical signals need review. Examples include a partial fetch without an explicit error, unusual duplicate rate, low new inserts, slow runtime, quality-flag movement, or a missing supporting diagnostic.

**Action:** Inspect the named app and signal, compare it with the next scheduled run, and document the result. Escalate if the warning repeats, spreads across apps, or is joined by a validation problem. A warning alone does not require stopping the pipeline.

## Failing

The run has a collection error, database loading or integrity problem, failed critical validation, or missing/corrupt required output.

**Action:** Stop downstream use of the run, preserve logs and artifacts, correct the cause, rerun the ingestion or monitoring step, and confirm every critical validation passes before treating the run as usable.

## Threshold maturity

Current behavior thresholds are initial project-specific thresholds based on only three prior comparable runs. They are not final production rules and should not trigger automatic intervention without review.
