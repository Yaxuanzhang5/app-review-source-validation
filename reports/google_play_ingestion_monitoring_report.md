# Google Play Ingestion Monitoring Report

## Overall status

- Monitoring status: **WARNING**
- Monitored run: `phase2_cadence_runB_followup_collection_20260714_163017`
- Ingestion status: `completed`
- Status reason: app warnings: TikTok, YouTube
- Generated at: 2026-07-17T03:56:39.396231+00:00

## Run summary

| Signal | Value |
|---|---:|
| Runtime | 30.02 seconds |
| Total fetched | 12,000 |
| New inserts | 3,753 |
| Duplicates skipped | 8,247 |
| Duplicate rate | 68.73% |
| App-level errors | 0 |
| Database row growth | 3,753 |
| Database file growth | 10.59 MB |
| Quality flags | 12,600 |
| Healthy / warning / failing apps | 8 / 2 / 0 |

## App-level health

| app_name | health_status | records_fetched | new_records_inserted | duplicates_skipped | duplicate_rate | runtime_seconds | quality_flag_count | status_reason |
|---|---|---|---|---|---|---|---|---|
| DoorDash | healthy | 1200 | 25 | 1175 | 97.92% | 0.93 | 1332 | all app-level checks within initial thresholds |
| Duolingo | healthy | 1200 | 3 | 1197 | 99.75% | 0.97 | 1296 | all app-level checks within initial thresholds |
| Google Maps | healthy | 1200 | 151 | 1049 | 87.42% | 0.84 | 981 | all app-level checks within initial thresholds |
| Instagram | healthy | 1200 | 1196 | 4 | 0.33% | 0.85 | 1589 | all app-level checks within initial thresholds |
| Netflix | healthy | 1200 | 152 | 1048 | 87.33% | 0.86 | 1491 | all app-level checks within initial thresholds |
| Reddit | healthy | 1200 | 61 | 1139 | 94.92% | 0.74 | 1455 | all app-level checks within initial thresholds |
| Spotify | healthy | 1200 | 456 | 744 | 62.00% | 0.77 | 1274 | all app-level checks within initial thresholds |
| TikTok | warning | 1200 | 406 | 794 | 66.17% | 0.79 | 616 | unusually high duplicate rate |
| Uber | healthy | 1200 | 309 | 891 | 74.25% | 0.78 | 1348 | all app-level checks within initial thresholds |
| YouTube | warning | 1200 | 994 | 206 | 17.17% | 1.93 | 1218 | unusually high duplicate rate |

## Validation result

- Checks run: 22
- Failed checks: 0
- Failed check names: None
- Duplicate review identity groups: 0
- Foreign-key violations: 0
- Raw review rows: 34,601
- Cleaned review rows: 34,601

## Threshold interpretation

The initial behavior thresholds use the three most recent prior comparable runs and are calculated separately for each app. Median and MAD are used because only a small historical sample is available and the apps have very different normal duplicate patterns.

A warning means the run completed but one or more signals should be reviewed. It does not automatically mean the pipeline failed. A failing status is reserved for collection failure, database loading or integrity failure, or a failed critical validation check.

Database growth in MB is reported only at the run level because SQLite file-page growth cannot be assigned reliably to individual apps.

These thresholds are project-specific starting points. They should be recalibrated after more routine production runs are collected.
