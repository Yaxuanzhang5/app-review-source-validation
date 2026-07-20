# Monitoring Threshold Calibration Report

## Scope

- Fixed setup: 10 apps, 1,200 newest reviews per app, English / United States
- Historical method: rolling replay with the three prior completed fixed-scope runs
- Completed runs replayed: 3
- App evaluations per profile: 30
- Controlled synthetic scenarios: 10
- New review collection performed: No

## Initial-profile completed-run replay

| run_label | status | healthy_apps | warning_apps | failing_apps | status_reason |
|---|---|---|---|---|---|
| phase2_cadence_runA_twice_daily_test | healthy | 10 | 0 | 0 | all replay checks within profile thresholds |
| phase2_cadence_runB_first_collection | healthy | 10 | 0 | 0 | all replay checks within profile thresholds |
| phase2_cadence_runB_followup_collection | warning | 8 | 2 | 0 | app warnings: TikTok, YouTube |

The initial profile marks Cadence Run A and Run B first collection healthy. It reproduces the useful Run B follow-up warning for TikTok and YouTube. Both apps exceeded their app-specific duplicate-rate thresholds, while the run completed, fetched all 12,000 expected records, had zero app-level errors, and passed all critical validations.

## Sensitivity comparison

| profile | completed_runs_tested | healthy_runs | warning_runs | failing_runs | app_evaluations | app_warnings | app_warning_rate | interpretation |
|---|---|---|---|---|---|---|---|---|
| sensitive | 3 | 0 | 3 | 0 | 30 | 7 | 23.33% | too sensitive for the current small baseline |
| initial | 3 | 2 | 1 | 0 | 30 | 2 | 6.67% | reasonable as an initial, non-production profile |
| loose | 3 | 3 | 0 | 0 | 30 | 0 | 0.00% | too loose; it suppresses the known Run B follow-up signals |

The sensitive profile is too reactive for the current three-run baseline: it marks all three completed replays warning and flags 7 of 30 app evaluations. The loose profile is too permissive: it marks all three runs healthy and removes the known TikTok and YouTube signals. The current initial profile produces one warning run and 2 warning app evaluations out of 30, so it is the most reasonable provisional choice among the tested profiles.

## Controlled scenario result

All 10 of 10 controlled scenarios matched their expected status. Hard failures correctly override warnings. Missing required run output, collection error, database load error, and critical validation failure all produce `failing`. Behavior-only anomalies produce `warning`. Informational observations remain `healthy`.

## Decision

Retain the current median + MAD profile without promoting it to a final production rule. The historical baseline is still small, and the earliest replay includes the Day 1 cold-start run. Recalculate after additional routine fixed-scope runs and evaluate persistence before changing margins or adding automated alerts.
