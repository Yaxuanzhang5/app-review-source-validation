# App Review Source Validation and Google Play Recurring Ingestion Pipeline

## Project overview

This repository documents the technical validation, database design, recurring ingestion testing, cadence analysis, and monitoring implementation for a public app-review data pipeline.

The work began by comparing Google Play and the iOS App Store as possible recurring review sources. Based on the source-validation results, Google Play was selected as the primary source for the first ingestion pilot. The project then moved through exploratory data-quality analysis, relational database design, automated repeated ingestion, controlled scale testing, cadence testing, and an automated monitoring layer.

The current pipeline uses Google Play reviews collected in English for the United States and stores raw reviews, cleaned review text, ingestion-run history, app-level run summaries, and quality flags in SQLite.

## Current project status

The following stages are complete:

1. Google Play and iOS source feasibility validation
2. Repeated-run stability and freshness testing
3. Google Play 10-app exploratory data-quality analysis
4. SQL database schema design
5. Automated recurring-ingestion pipeline prototype
6. Phase 2 controlled 10-app scale testing
7. Run A and Run B cadence analysis
8. Automated ingestion monitoring layer

The current operating recommendation is:

- use Google Play as the primary recurring review source
- use once-daily collection as the default schedule
- consider twice-daily collection only for high-turnover apps such as YouTube and Instagram when returned-window coverage is more important than efficiency
- keep duplicate-heavy apps on once-daily collection
- use the automated monitoring report to review each new run

Additional cadence testing is not currently required. The next operational focus is monitoring and gradual threshold recalibration as more routine runs become available.

## Test applications

The controlled 10-app setup uses:

| App | Google Play app ID |
|---|---|
| YouTube | `com.google.android.youtube` |
| TikTok | `com.zhiliaoapp.musically` |
| Spotify | `com.spotify.music` |
| Instagram | `com.instagram.android` |
| Uber | `com.ubercab` |
| DoorDash | `com.dd.doordash` |
| Duolingo | `com.duolingo` |
| Google Maps | `com.google.android.apps.maps` |
| Netflix | `com.netflix.mediaclient` |
| Reddit | `com.reddit.frontpage` |

## Phase 1: source validation

### Google Play

The initial Google Play validation used YouTube, TikTok, and Spotify with a target of 2,000 newest reviews per app.

Key results:

- 6,000 reviews were returned across the three apps
- each app returned the requested 2,000 reviews
- review IDs were unique within each app batch
- core fields and review timestamps were available
- current reviews were returned
- repeated collection was technically feasible

Google Play provided the most consistent combination of volume, metadata, pagination support, and recurring-ingestion behavior.

### iOS App Store public feeds

The iOS public review feeds were technically accessible, but the results were more dependent on app, country, and page availability. Some app-country combinations returned usable data, while others returned empty or lower-volume results. Cross-country retrieval also produced more duplicate and coverage-management issues.

The iOS source remains useful as a secondary or supplementary source, but it was not selected as the primary source for the first recurring-ingestion pipeline.

## Google Play exploratory data-quality analysis

The expanded Google Play analysis used the same 10 apps later adopted for Phase 2, with 1,200 newest reviews per app.

Key results:

- 12,000 reviews were collected
- all 12,000 review identities were unique under the tested batch
- core review IDs, scores, and timestamps were complete
- app-version and developer-reply fields were naturally incomplete for many reviews
- repeated or generic review text existed even when review IDs were unique
- approximately 39.5% of reviews met at least one low-signal text condition in the exploratory quality analysis

These results supported keeping the original response fields, preserving raw and cleaned text separately, and recording quality flags instead of deleting potentially low-signal reviews.

## Database and deduplication design

The pipeline uses a relational SQLite design to keep source metadata, ingestion history, review records, cleaned text, and quality flags linked and reviewable.

The central duplicate identity is:

```text
source + app_id + review_id
```

This identity prevents the same source review from being inserted as a new database row during later runs.

The database design supports:

- app and source metadata
- run-level ingestion metadata
- app-level run targets and summaries
- raw review fields and raw JSON
- cleaned review text linked to the raw review
- review and collection timestamps
- quality flags
- duplicate prevention
- run-level and app-level validation

The schema documentation is stored in:

- `database_design/google_play_review_schema.md`
- `database_design/schema.sql`

The primary working database is stored under `database/`.

## Automated recurring-ingestion pipeline

Before the controlled 10-app phase, the automated pipeline was tested through repeated collections using a smaller three-app database. The prototype confirmed that the pipeline could:

- record a separate ingestion-run row for each execution
- preserve app-level run summaries
- insert only database-new review identities
- skip existing review identities
- keep raw and cleaned review text linked
- preserve quality flags
- maintain relational and foreign-key integrity across repeated runs

The controlled Phase 2 work then expanded the same operating logic to 10 apps and 1,200 requested reviews per app.

## Phase 2: controlled scale and repeated runs

### Fixed setup

- Source: Google Play
- Apps: 10
- Target: 1,200 newest reviews per app
- Total requested per run: 12,000
- Language: English
- Country: United States
- Sort order: newest
- Duplicate identity: `source + app_id + review_id`

### Complete run history

| Run | Frequency label | Runtime | Fetched | New inserts | Duplicates skipped | Duplicate rate | Errors | Review rows after | DB growth |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Phase 2 Day 1 | Once-daily baseline | 23.27 s | 12,000 | 12,000 | 0 | 0.00% | 0 | 12,000 | 23.66 MB |
| Phase 2 Day 2 | Daily follow-up | 75.80 s | 12,000 | 156 | 11,844 | 98.70% | 0 | 12,156 | 4.70 MB |
| Phase 2 Day 3 | Controlled repeated run | 29.27 s | 12,000 | 5,659 | 6,341 | 52.84% | 0 | 17,815 | 13.57 MB |
| Cadence Run A | Same-day follow-up | 28.14 s | 12,000 | 4,395 | 7,605 | 63.38% | 0 | 22,210 | 11.76 MB |
| Run B first collection | New Run B baseline | 30.76 s | 12,000 | 8,638 | 3,362 | 28.02% | 0 | 30,848 | 18.56 MB |
| Cadence Run B follow-up | Higher-frequency follow-up | 30.02 s | 12,000 | 3,753 | 8,247 | 68.73% | 0 | 34,601 | 10.59 MB |

Final Phase 2 database state:

- 6 completed controlled runs
- 60 app-level run-summary rows
- 34,601 raw review rows
- 34,601 cleaned review rows
- 75,918 quality-flag rows
- 0 duplicate review-identity groups
- 0 raw reviews without cleaned rows
- 0 cleaned rows without raw reviews
- 0 orphan quality flags
- 0 foreign-key violations
- final SQLite database size: 84.68 MB

## Cadence analysis

### Controlled run comparison

| Cadence test | Mean interval | Fetched | New DB inserts | Duplicate rate | Posted between collections | Older reviews surfaced later | Median source lag | Runtime |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Run A | 17.16 h | 12,000 | 4,395 | 63.38% | 0 | 4,395 | 24.04 h | 28.14 s |
| Run B follow-up | 14.66 h | 12,000 | 3,753 | 68.73% | 0 | 3,753 | 24.04 h | 30.02 s |

The Run B first collection occurred 100.65 hours after Run A, so it is treated as a new baseline rather than a separate twice-daily outcome. It inserted 8,638 reviews, including 8,015 posted after the prior Run A boundary and 623 older reviews that surfaced later.

### Timestamp finding

The controlled cadence tests distinguished between:

1. review identities that were new to the database
2. reviews actually posted between the two collections

Both controlled cadence runs found zero database-new reviews with timestamps proving that they were posted between the app-specific collection boundaries. All 8,148 combined new inserts from Run A and Run B follow-up were older reviews that appeared in the returned 1,200-review window later.

Therefore, twice-daily collection may improve returned-window coverage for high-turnover apps, but the completed tests did not demonstrate a true posting-time freshness benefit.

The approximately 24-hour returned-window lag was consistent in the two controlled tests, but it should not be interpreted as a universal Google Play rule.

### App-level cadence result

| App | Run A new-insert rate | Run B new-insert rate | Run A duplicate rate | Run B duplicate rate | Recommendation |
|---|---:|---:|---:|---:|---|
| YouTube | 99.92% | 82.83% | 0.08% | 17.17% | Twice-daily candidate for returned-window coverage |
| TikTok | 51.83% | 33.83% | 48.17% | 66.17% | Monitor before changing cadence |
| Spotify | 48.33% | 38.00% | 51.67% | 62.00% | Monitor before changing cadence |
| Instagram | 99.83% | 99.67% | 0.17% | 0.33% | Twice-daily candidate for returned-window coverage |
| Uber | 26.42% | 25.75% | 73.58% | 74.25% | Once-daily candidate |
| DoorDash | 6.08% | 2.08% | 93.92% | 97.92% | Once-daily candidate |
| Duolingo | 0.50% | 0.25% | 99.50% | 99.75% | Once-daily candidate |
| Google Maps | 15.33% | 12.58% | 84.67% | 87.42% | Once-daily candidate |
| Netflix | 10.25% | 12.67% | 89.75% | 87.33% | Once-daily candidate |
| Reddit | 7.75% | 5.08% | 92.25% | 94.92% | Once-daily candidate |

### Cadence recommendation

A blanket twice-daily schedule is not supported.

- Twice-daily coverage candidates: YouTube and Instagram
- Once-daily candidates: Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit
- Continue monitoring before changing cadence: TikTok and Spotify

YouTube and Instagram are twice-daily candidates only when returned-window coverage is more important than efficiency. No posting-time freshness benefit was demonstrated for these apps.

## Ingestion monitoring layer

The latest project stage adds a lightweight automated monitoring layer on top of the existing ingestion pipeline. It produces a run-level report and app-level health classifications without requiring a separate dashboard.

### Signals monitored

- ingestion success or failure
- run runtime
- total fetched records
- new database inserts
- duplicates skipped
- duplicate rate
- app-level errors
- database row and file-size growth
- quality-flag counts and rates
- missing or corrupted expected outputs
- abnormal app behavior compared with recent runs
- database and relationship validation results

### Health classification

Each app and the overall run are classified as:

- `healthy`: collection completed and monitored signals remain within the initial thresholds
- `warning`: collection completed, but at least one behavior or output needs review
- `failing`: collection failed, database loading or integrity failed, or a critical validation check did not pass

### Initial threshold method

The first thresholds use the three most recent prior comparable runs:

1. Phase 2 Day 3 controlled repeated run
2. Cadence Run A
3. Run B first-collection baseline

Thresholds are calculated separately for each app using the median and median absolute deviation (MAD). Practical minimum margins are included because only three comparable reference runs are currently available.

| Signal | Initial warning rule |
|---|---|
| New inserts | Current value below `median − max(3×MAD, 50% of median, 25 records)` |
| Duplicate rate | Current rate above `median + max(3×MAD, 0.10)` |
| App runtime | Current runtime above `median + max(3×MAD, 1 second)` |
| Run runtime | Current runtime above `median + max(3×MAD, 15 seconds)` |
| Quality flags | Absolute rate change above `max(3×MAD, 0.10 flags per fetched record)` |

These are transparent project-specific starting thresholds, not universal Google Play limits. They should be recalibrated after more routine production runs are collected.

## Current monitoring result

The monitoring layer was executed against the final Run B follow-up database.

| Signal | Result |
|---|---:|
| Ingestion status | `completed` |
| Monitoring status | `warning` |
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
| Validation checks | 22 passed, 0 failed |

TikTok and YouTube are classified as `warning` because their duplicate rates are above their own initial history-based thresholds:

| App | Current duplicate rate | Initial warning threshold | Monitoring status |
|---|---:|---:|---|
| TikTok | 66.17% | 57.00% | `warning` |
| YouTube | 17.17% | 10.08% | `warning` |

This warning does not mean that ingestion failed. The run completed, all 12,000 expected records were fetched, there were no app-level errors, and all 22 validation checks passed.

The monitoring result also does not change the cadence conclusion. YouTube still returned 994 new database inserts out of 1,200 fetched reviews and remains a possible twice-daily exception when returned-window coverage is prioritized. The warning only indicates a behavior change that should be reviewed over future runs.

## Monitoring outputs

The monitoring notebook generates:

- `outputs/monitoring_run_summary.csv`
- `outputs/monitoring_app_health.csv`
- `outputs/monitoring_app_thresholds.csv`
- `outputs/monitoring_rule_definitions.csv`
- `outputs/monitoring_validation_checks.csv`
- `outputs/monitoring_alerts.csv`
- `outputs/monitoring_source_manifest_validation.csv`
- `outputs/monitoring_output_manifest.csv`
- `outputs/monitoring_metadata.json`
- `reports/google_play_ingestion_monitoring_report.md`
- `reports/monitoring_design_and_thresholds.md`

The monitoring notebook is:

- `notebooks/Google_Play_Ingestion_Monitoring_Layer.ipynb`

## Repository structure

```text
app-review-source-validation/
├── README.md
├── requirements.txt
├── data/
├── database/
├── database_design/
│   ├── google_play_review_schema.md
│   └── schema.sql
├── notebooks/
│   └── Google_Play_Ingestion_Monitoring_Layer.ipynb
├── outputs/
│   ├── monitoring_run_summary.csv
│   ├── monitoring_app_health.csv
│   ├── monitoring_app_thresholds.csv
│   ├── monitoring_rule_definitions.csv
│   ├── monitoring_validation_checks.csv
│   ├── monitoring_alerts.csv
│   ├── monitoring_source_manifest_validation.csv
│   ├── monitoring_output_manifest.csv
│   └── monitoring_metadata.json
└── reports/
    ├── phase2_cadence_runA_runB_final_report.md
    ├── google_play_ingestion_monitoring_report.md
    └── monitoring_design_and_thresholds.md
```

## How to reproduce the monitoring report

1. Open `notebooks/Google_Play_Ingestion_Monitoring_Layer.ipynb` in Google Colab.
2. Run all cells in order.
3. When prompted, upload the final Phase 2 Run B complete-report ZIP package.
4. The notebook validates the package and database.
5. It automatically identifies the latest completed run.
6. It builds app-specific thresholds from the three prior comparable runs.
7. It generates the run summary, app-health classifications, alerts, validation outputs, metadata, and Markdown monitoring report.

The monitoring notebook does not perform another cadence collection. It evaluates the completed Phase 2 evidence and can be reused after future ingestion runs.

## Key conclusions

1. Google Play is the primary source for the recurring review-ingestion pilot.
2. The SQLite ingestion design successfully preserves raw reviews, cleaned text, run history, deduplication, and quality flags.
3. Six controlled Phase 2 runs completed with no app-level collection errors and no database relationship failures.
4. A blanket twice-daily schedule is not supported.
5. Once-daily collection should remain the default.
6. YouTube and Instagram may use twice-daily collection only when returned-window coverage is more important than efficiency.
7. The cadence tests did not demonstrate a true posting-time freshness benefit.
8. The monitoring layer now provides automated `healthy`, `warning`, and `failing` classifications for each run.
9. The current monitoring warning is a review signal caused by app-level duplicate-rate changes, not a pipeline failure.

## Limitations

- Results apply to the tested apps, English/United States configuration, collection dates, and fixed 1,200-review returned window.
- Public scraper behavior and Google Play response behavior may change over time.
- New database inserts are not automatically newly posted reviews.
- A fixed newest-review window may turn over quickly for high-activity apps.
- App-version and developer-reply fields are naturally missing for many reviews.
- SQLite file-size growth is reported at run level and cannot be assigned reliably to individual apps.
- The first monitoring thresholds use only three comparable reference runs and should be recalibrated as more operating history becomes available.

## Recommended next operating step

Continue with once-daily collection as the default and run the monitoring layer after each ingestion. Review warnings before changing app-specific schedules. After enough routine history is available, recalculate the initial thresholds using a larger baseline and evaluate whether YouTube or Instagram requires a permanent twice-daily coverage exception.
