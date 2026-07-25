# App Review Source Validation and Google Play Recurring Ingestion Pipeline

## Project overview

This repository documents the design and validation of a recurring public app-review data pipeline. The project began with source feasibility testing for Google Play and the iOS App Store and then progressed through repeated collection tests, exploratory data-quality analysis, relational database design, controlled ingestion runs, cadence analysis, automated monitoring, monitoring-threshold calibration, and a lightweight feature-engineering layer.

Google Play was selected as the primary source for the first recurring-ingestion pilot because it provided the most consistent combination of review volume, core metadata, pagination behavior, and repeated-collection feasibility under the tested setup.

The current pipeline stores raw review records, cleaned review text, ingestion-run history, app-level run summaries, and quality flags in SQLite. The feature-engineering layer creates transparent review-level features and app-level aggregates from validated cleaned data. The newest downstream layer adds an exploratory rating-derived weak-sentiment baseline with strict rating-field leakage controls. It is not a production sentiment system.

## Current project status

The following stages are complete:

1. Google Play and iOS App Store source feasibility validation
2. Repeated-run stability, duplicate, and freshness testing
3. Google Play 10-app exploratory data-quality analysis
4. Relational SQLite schema and deduplication design
5. Automated recurring-ingestion pipeline prototype
6. Phase 2 controlled 10-app scale testing
7. Run A and Run B cadence analysis
8. Automated ingestion monitoring layer
9. Monitoring-threshold calibration and operational response documentation
10. Lightweight review feature engineering v0
11. Rating-derived weak sentiment baseline v0

The current operating workflow is:

```text
normal ingestion run
        ↓
monitoring and critical validation
        ↓
healthy: continue
warning: review and document the signal, then continue only if the run remains usable
failing: stop downstream use, correct the failure, and rerun
        ↓
feature generation from validated cleaned reviews
        ↓
weak-label EDA and leakage-controlled linear baseline
        ↓
error analysis and later model-design work
```

The current operating recommendation is:

- use Google Play as the primary recurring review source
- use once-daily collection as the default schedule
- consider twice-daily collection only for YouTube and Instagram when returned-window coverage is more important than collection efficiency
- continue monitoring TikTok and Spotify before changing their cadence
- keep Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit on once-daily collection under the current setup
- run the monitoring layer after normal ingestion runs
- treat the current median/MAD monitoring thresholds as initial rules rather than final production thresholds
- generate the feature layer only after ingestion and hard-failure validation complete

## Controlled test applications

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
- review IDs were unique within each tested app batch
- core fields and review timestamps were available
- current reviews were returned
- repeated collection was technically feasible

Google Play provided the most consistent combination of volume, metadata, pagination support, and recurring-ingestion behavior.

### iOS App Store public feeds

The iOS public review feeds were technically accessible, but results were more dependent on app, country, and page availability. Some app-country combinations returned usable review data, while others returned empty or lower-volume responses. Cross-country collection also introduced more duplicate and coverage-management issues.

The iOS source remains useful as a possible secondary or supplementary source, but it was not selected as the primary source for the first recurring-ingestion pipeline.

## Google Play exploratory data-quality analysis

The expanded Google Play analysis used the same 10 apps later adopted for Phase 2, with 1,200 newest reviews requested per app.

Key results:

- 12,000 reviews were collected
- all 12,000 review identities were unique within the tested batch
- core review IDs, scores, and timestamps were complete
- app-version and developer-reply fields were naturally incomplete for many reviews
- repeated or generic review text existed even when review IDs were unique
- approximately 39.5% of reviews met at least one low-signal text condition in the exploratory analysis

These findings supported preserving raw and cleaned text separately, retaining source metadata, and recording quality flags rather than deleting potentially low-signal reviews.

## Database and deduplication design

The pipeline uses a relational SQLite design to keep source metadata, ingestion history, review records, cleaned text, and quality flags linked and auditable.

The central duplicate identity is:

```text
source + app_id + review_id
```

This identity prevents a review already stored in the database from being inserted again as a new review row during later runs.

The database design supports:

- app and source metadata
- run-level ingestion metadata
- app-level run targets and summaries
- raw review fields and raw JSON
- cleaned review text linked to the raw review
- review and collection timestamps
- developer-reply availability
- quality flags
- duplicate prevention
- run-level and app-level validation
- relational and foreign-key integrity checks

Schema documentation is stored under `database_design/`, and the working SQLite database is stored under `database/` or inside the validated Phase 2 database package.

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

### Complete controlled run history

| Run | Frequency label | Runtime | Fetched | New inserts | Duplicates skipped | Duplicate rate | Errors | Review rows after | DB growth |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Phase 2 Day 1 | Once-daily baseline | 23.27 s | 12,000 | 12,000 | 0 | 0.00% | 0 | 12,000 | 23.66 MB |
| Phase 2 Day 2 | Daily follow-up | 75.80 s | 12,000 | 156 | 11,844 | 98.70% | 0 | 12,156 | 4.70 MB |
| Phase 2 Day 3 | Controlled repeated run | 29.27 s | 12,000 | 5,659 | 6,341 | 52.84% | 0 | 17,815 | 13.57 MB |
| Cadence Run A | Same-day follow-up | 28.14 s | 12,000 | 4,395 | 7,605 | 63.38% | 0 | 22,210 | 11.76 MB |
| Run B first collection | New Run B baseline | 30.76 s | 12,000 | 8,638 | 3,362 | 28.02% | 0 | 30,848 | 18.56 MB |
| Cadence Run B follow-up | Higher-frequency follow-up | 30.02 s | 12,000 | 3,753 | 8,247 | 68.73% | 0 | 34,601 | 10.59 MB |

### Final Phase 2 database state

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

### Controlled cadence comparison

| Cadence test | Mean interval | Fetched | New DB inserts | Duplicate rate | Posted between collections | Older reviews surfaced later | Median source lag | Runtime |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Run A | 17.16 h | 12,000 | 4,395 | 63.38% | 0 | 4,395 | 24.04 h | 28.14 s |
| Run B follow-up | 14.66 h | 12,000 | 3,753 | 68.73% | 0 | 3,753 | 24.04 h | 30.02 s |

The Run B first collection occurred 100.65 hours after Run A, so it is treated as a new baseline rather than as a separate twice-daily result. It inserted 8,638 reviews, including 8,015 reviews posted after the prior Run A boundary and 623 older reviews that surfaced later.

### Timestamp finding

The cadence analysis distinguished between:

1. review identities that were new to the database
2. reviews that were actually posted between two collection boundaries

Both controlled higher-frequency runs found zero database-new reviews whose source timestamps proved that they were posted between the app-specific collections. All 8,148 combined new inserts from Run A and the Run B follow-up were older reviews that entered the returned 1,200-review window later.

Therefore, higher-frequency collection may improve returned-window coverage for high-turnover apps, but these tests did not demonstrate a true posting-time freshness benefit.

The approximately 24-hour returned-window lag was consistent in the two controlled cadence tests, but it should not be interpreted as a universal Google Play rule.

### App-level cadence recommendation

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

A blanket twice-daily schedule is not supported. YouTube and Instagram are possible twice-daily exceptions only when returned-window coverage is more important than efficiency.

## Ingestion monitoring layer

The monitoring layer creates run-level and app-level health classifications without requiring a separate dashboard.

### Signals monitored

- ingestion completion or failure
- total and app-level runtime
- total fetched records
- new database inserts
- duplicates skipped and duplicate rate
- app-level collection errors
- database row and file-size growth
- quality-flag counts and rates
- missing or corrupted required outputs
- abnormal app behavior compared with recent comparable runs
- database relationship and integrity checks

### Health classifications

- `healthy`: collection completed and monitored signals remain within the current initial thresholds
- `warning`: collection completed and remains usable, but at least one non-critical behavior or output needs review
- `failing`: collection failed, the database could not be loaded or validated, a critical output is missing or corrupt, or a critical validation check failed

### Current monitored result

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

TikTok and YouTube were classified as `warning` because their duplicate rates exceeded their own initial history-based thresholds. This did not indicate a collection or database failure: the run completed, all 12,000 records were fetched, no app-level errors occurred, and every critical validation passed.

## Monitoring-threshold calibration and operational response

The calibrated monitoring design separates three condition classes:

- **Hard failure:** failed collection, database loading or integrity failure, failed critical validation, or a missing/corrupt required output. Overall result: `failing`.
- **Warning:** the run completed and remains usable, but a non-critical signal needs review. Overall result: `warning`.
- **Informational observation:** normal or expected behavior that is recorded without requiring intervention. Overall result remains `healthy`.

### Operational response

| Status | Required action |
|---|---|
| `healthy` | Record the run and continue the normal schedule. |
| `warning` | Inspect the named app and signal, compare it with the next scheduled run, and document whether it persists. |
| `failing` | Stop downstream use, preserve logs and artifacts, correct the cause, rerun, and confirm that all critical validations pass. |

### Calibration evidence

Threshold calibration used rolling replay on three completed comparable runs and 10 controlled synthetic scenarios. The synthetic scenarios were explicitly labeled and were used only to test failure conditions that did not occur in the real completed-run history.

| Profile | Completed runs classified with warning | App warnings | Assessment |
|---|---:|---:|---|
| Sensitive | 3 of 3 | 7 of 30 | Too sensitive for the current small baseline |
| Initial | 1 of 3 | 2 of 30 | Reasonable as an initial, non-production profile |
| Loose | 0 of 3 | 0 of 30 | Too loose; removes useful TikTok and YouTube signals |

The current median plus median absolute deviation (MAD) profile is retained. It reproduces the Run B follow-up warning for TikTok and YouTube while leaving Cadence Run A and the Run B first collection healthy.

The baseline still contains only three prior comparable runs. The thresholds are therefore documented as **initial operating rules**, not final production rules.

## Lightweight feature engineering v0

### Objective and scope

The feature-engineering layer converts the validated cleaned review data into a transparent review-level feature table and basic app-level aggregates.

The first version is intentionally simple. Its purpose is to support later:

- exploratory data analysis
- review segmentation
- sentiment-analysis design
- topic-modeling design
- issue-detection design
- data-quality and language-routing decisions

No sentiment model, topic model, issue classifier, or other machine-learning model is trained in v0.

### Operational dependency

The feature layer is downstream of ingestion monitoring:

- a hard monitoring failure stops feature generation or downstream feature use
- a warning must be reviewed and documented, but it does not automatically invalidate a completed usable run
- the feature snapshot is generated from validated cleaned review rows

### Feature input and privacy scope

The feature base joins validated records from the Phase 2 raw-review, cleaned-review, app-metadata, and ingestion-run tables.

The exported feature table retains only fields needed for traceability and analysis. User names, user images, and raw JSON are excluded from the exported feature table.

### Review-level feature definitions

Detailed definitions for all 37 exported fields are stored in:

- `outputs/feature_definitions_v0.csv`
- `reports/feature_engineering_v0_feature_dictionary.md`

The principal v0 features are summarized below.

| Feature | Meaning and calculation | Possible later use | Reliability note |
|---|---|---|---|
| `app_id`, `app_name` | Stable package identifier and human-readable app name from source metadata | App grouping, joins, and app-level EDA | High |
| `review_id`, `review_key`, `run_id` | Source review ID, stable database key, and first-insert ingestion run | Traceability and validation | High |
| `score` | Source-provided 1–5 rating | Rating summaries and later target/validation work | High |
| `rating_group` | `low` for ratings 1–2, `middle` for rating 3, and `high` for ratings 4–5 | Simple rating segmentation | High; deterministic project grouping |
| `low_rating_flag` | 1 when the rating is 1 or 2; otherwise 0 | Low-rating shares and issue-focused EDA | High |
| `review_char_count` | Number of characters in cleaned review text | Length distributions and short-review checks | High |
| `review_word_count` | Count of simple Unicode word tokens in cleaned text | Text-length EDA and low-signal screening | Medium-high |
| `alphanumeric_char_count` | Number of alphabetic or numeric characters | Separate usable text from punctuation/emoji-only content | High |
| `short_review_flag` | 1 when `review_char_count < 20` | Short-review share and EDA filtering | Medium; threshold is project-defined |
| `low_signal_flag` | 1 when `review_word_count <= 2` or `alphanumeric_char_count < 10` | Identify reviews requiring caution in text analysis | Medium; short reviews can still be meaningful |
| `duplicate_identity_flag` | Duplicate check on `source + app_id + review_id` | Deduplication guard | High; all values are 0 after database deduplication |
| `same_app_text_frequency` | Number of identical normalized cleaned texts within the same app | Identify repeated or generic text | Medium |
| `repeated_text_flag` | 1 when the normalized text appears more than once within the same app | Repeated-text screening | Medium; repeated text is not the same as duplicate identity |
| `review_created_at`, `review_date` | Source review timestamp and extracted UTC date | Temporal EDA and daily review trends | High |
| `fetched_at`, `collection_date` | First stored collection timestamp and extracted UTC date | Collection cohorts and traceability | High |
| `review_age_hours_at_collection` | Hours between the review timestamp and first stored collection timestamp | Source-lag and returned-window analysis | High mathematically; source behavior affects interpretation |
| `has_developer_reply` | 1 when a developer reply is present | Reply-availability and support-response EDA | High for presence; not a reply-quality measure |
| `language_group` | `english_likely`, `non_english_likely`, or `undetermined` from a conservative deterministic rule | Language-aware EDA and later routing | Low-medium; not a trained language detector |
| `non_english_flag` | 1 for likely non-English, 0 for likely English, and blank for undetermined | Estimate non-English coverage while preserving uncertainty | Low-medium |
| `language_detection_reason` | Auditable reason produced by the language heuristic | Review and later replacement of the rule | Medium as a rule trace |
| `issue_indicator_count` | Number of issue-keyword categories matched | Prioritize multi-indicator reviews | Low-medium |
| `any_issue_indicator_flag` | 1 when at least one issue category matched | Basic issue-share aggregation | Low-medium; not a verified issue label |

### Simple keyword issue indicators

Seven transparent, case-insensitive keyword groups are included:

| Feature | Example concepts screened |
|---|---|
| `issue_crash_bug_flag` | crash, bug, glitch, error, broken, freeze, not working |
| `issue_performance_loading_flag` | slow, lag, loading, buffering, stuck, hanging, performance |
| `issue_login_account_flag` | login, account, password, verification, suspension, ban |
| `issue_payment_billing_flag` | payment, billing, charge, subscription, refund, price, purchase, premium |
| `issue_ads_flag` | ad, advertising, commercial, sponsored, promotion |
| `issue_update_version_flag` | update, version, latest update, downgrade |
| `issue_support_service_flag` | support, customer service, customer care, help center, response, reply, agent |

These are screening indicators only. A keyword match does not prove that an issue occurred, and a non-match does not prove that no issue occurred. The rules do not fully understand context, negation, misspellings, or non-English issue wording.

### Basic app-level aggregates

The app-level output includes:

- review volume
- average rating
- low-, middle-, and high-rating shares
- average and median review character counts
- average review word count
- short-review share
- low-signal share
- repeated-text share
- developer-reply share
- likely non-English share
- non-English share among classifiable reviews
- language-undetermined share
- average review age at first collection
- share matching at least one issue indicator
- share matching each of the seven issue indicators

### Overall feature snapshot

The v0 feature table preserves all validated cleaned review rows.

| Metric | Result |
|---|---:|
| Review rows | 34,601 |
| Apps | 10 |
| Exported feature columns | 37 |
| Average rating | 3.725 |
| Low-rating share | 28.75% |
| Short-review share | 45.01% |
| Low-signal share under the v0 rule | 37.26% |
| Repeated cleaned-text share within app | 23.01% |
| Developer-reply share | 12.81% |
| Likely English share | 57.60% |
| Likely non-English share of all reviews | 2.05% |
| Language-undetermined share | 40.35% |
| Likely non-English share among classifiable reviews | 3.43% |
| Share matching at least one issue indicator | 17.90% |
| Duplicate review identities in the persisted feature snapshot | 0 |

The high `undetermined` language share mainly reflects the large number of short reviews. The v0 rule intentionally preserves uncertainty instead of forcing a potentially unreliable English/non-English label.

### App-level feature snapshot

| App | Reviews | Average rating | Low-rating share | Short-review share | Low-signal share | Developer-reply share | Any issue-indicator share |
|---|---:|---:|---:|---:|---:|---:|---:|
| DoorDash | 1,975 | 3.101 | 44.20% | 23.49% | 16.81% | 0.00% | 27.44% |
| Duolingo | 2,098 | 4.500 | 7.63% | 39.66% | 30.46% | 0.00% | 5.67% |
| Google Maps | 2,635 | 3.614 | 31.61% | 46.26% | 40.30% | 21.06% | 13.70% |
| Instagram | 6,045 | 3.847 | 26.22% | 52.56% | 44.35% | 0.00% | 18.48% |
| Netflix | 2,365 | 3.519 | 33.66% | 34.33% | 28.84% | 0.00% | 19.83% |
| Reddit | 1,991 | 2.984 | 48.37% | 30.94% | 23.91% | 0.00% | 20.14% |
| Spotify | 4,174 | 3.883 | 23.14% | 35.03% | 26.83% | 10.85% | 26.59% |
| TikTok | 4,059 | 3.839 | 25.77% | 49.20% | 39.34% | 84.21% | 16.01% |
| Uber | 3,440 | 3.839 | 27.01% | 48.28% | 42.82% | 0.23% | 13.17% |
| YouTube | 5,819 | 3.660 | 30.88% | 57.28% | 48.62% | 0.00% | 16.72% |

These values describe the collected and deduplicated database snapshot. They should not be interpreted as general rankings of the apps.

### Issue-indicator rates

| Indicator | Reviews matched | Share of reviews |
|---|---:|---:|
| Login / account | 1,626 | 4.70% |
| Payment / billing | 1,511 | 4.37% |
| Ads | 1,185 | 3.42% |
| Update / version | 1,101 | 3.18% |
| Crash / bug | 1,022 | 2.95% |
| Performance / loading | 588 | 1.70% |
| Support / service | 583 | 1.68% |

### Most useful and least reliable features

The strongest v0 features are:

- app and review identifiers
- source-provided score and deterministic rating group
- review and collection timestamps
- deterministic review-length measures
- developer-reply presence
- duplicate-identity validation

These fields are source-provided or deterministically calculated and can directly support EDA, segmentation, joins, and validation.

The following fields should be used with caution:

- `short_review_flag`
- `low_signal_flag`
- `same_app_text_frequency`
- `repeated_text_flag`
- `has_developer_reply` when comparing apps with very different reply practices

The least reliable v0 fields are:

- `language_group`
- `non_english_flag`
- the seven keyword issue indicators
- `issue_indicator_count`
- `any_issue_indicator_flag`

These heuristic fields are appropriate for screening and descriptive EDA, but they should not be presented as ground-truth language, sentiment, topic, or issue labels.

### Feature validation

All 32 database, review-level, and app-level feature checks passed. The validation confirmed:

- 34,601 raw rows and 34,601 cleaned rows
- one feature row for every cleaned review row
- 34,601 complete and unique review keys
- all 10 expected apps present
- complete scores within the 1–5 domain
- complete and valid rating groups
- correct and non-negative text-length fields
- parseable review and collection timestamps
- non-negative review age at collection
- valid binary-flag domains
- reconciled issue counts and any-issue flags
- 0 duplicate review identities after database deduplication
- 10 app-aggregate rows
- aggregate review volume equal to 34,601
- rating shares reconciling to one within rounding tolerance
- weighted app-average rating matching the review-level average
- no raw/cleaned orphan rows
- no foreign-key violations

The source Phase 2 package was also validated against its manifest before the feature table was generated. All 22 package files passed existence, file-size, and SHA-256 validation.

## Feature-engineering outputs

```text
notebooks/
└── Google_Play_Review_Feature_Engineering_v0.ipynb

outputs/
├── review_features_v0.csv
├── review_feature_sample_v0.csv
├── app_feature_aggregates_v0.csv
├── feature_definitions_v0.csv
├── feature_quality_assessment_v0.csv
├── feature_validation_checks_v0.csv
├── feature_engineering_source_validation_v0.csv
├── feature_issue_indicator_rates_v0.csv
├── feature_engineering_metadata_v0.json
└── feature_engineering_output_manifest_v0.csv

reports/
├── google_play_feature_engineering_v0_report.md
├── feature_engineering_v0_feature_dictionary.md
└── README_feature_engineering_v0_update.md
```

Important feature artifacts:

- `review_features_v0.csv`: complete 34,601-row review-level feature table
- `review_feature_sample_v0.csv`: 30-row reproducible sample with three reviews per app
- `app_feature_aggregates_v0.csv`: one app-level summary row for each of the 10 apps
- `feature_definitions_v0.csv`: structured definitions, calculations, possible uses, and limitations
- `feature_quality_assessment_v0.csv`: assessment of the most useful and least reliable feature groups
- `feature_validation_checks_v0.csv`: 32 passed validation checks
- `feature_engineering_source_validation_v0.csv`: source-package manifest validation
- `feature_issue_indicator_rates_v0.csv`: overall rates for the seven issue indicators
- `feature_engineering_metadata_v0.json`: configuration, thresholds, source hashes, and summary metrics
- `feature_engineering_output_manifest_v0.csv`: file existence, size, and SHA-256 manifest for the feature deliverables
- `google_play_feature_engineering_v0_report.md`: concise findings and reliability report
- `feature_engineering_v0_feature_dictionary.md`: complete readable feature dictionary

## Repository structure

The repository contains the notebooks, outputs, reports, database artifacts, and schema documentation produced across the project stages. The structure below highlights the major current components rather than every historical export.

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
│   ├── Google_Play_Ingestion_Monitoring_Layer.ipynb
│   ├── Google_Play_Monitoring_Threshold_Calibration.ipynb
│   └── Google_Play_Review_Feature_Engineering_v0.ipynb
├── outputs/
│   ├── monitoring_*.csv
│   ├── monitoring_*.json
│   ├── monitoring_calibration_*.csv
│   ├── monitoring_calibration_*.json
│   ├── review_features_v0.csv
│   ├── review_feature_sample_v0.csv
│   ├── app_feature_aggregates_v0.csv
│   ├── feature_definitions_v0.csv
│   ├── feature_quality_assessment_v0.csv
│   ├── feature_validation_checks_v0.csv
│   ├── feature_engineering_source_validation_v0.csv
│   ├── feature_issue_indicator_rates_v0.csv
│   ├── feature_engineering_metadata_v0.json
│   └── feature_engineering_output_manifest_v0.csv
└── reports/
    ├── phase2_cadence_runA_runB_final_report.md
    ├── google_play_ingestion_monitoring_report.md
    ├── monitoring_design_and_thresholds.md
    ├── monitoring_threshold_calibration_report.md
    ├── monitoring_operations_guide.md
    ├── google_play_feature_engineering_v0_report.md
    ├── feature_engineering_v0_feature_dictionary.md
    └── README_feature_engineering_v0_update.md
```

## Reproduction instructions

### Reproduce the ingestion monitoring report

1. Open `notebooks/Google_Play_Ingestion_Monitoring_Layer.ipynb` in Google Colab or a compatible Jupyter environment.
2. Run all cells in order.
3. Upload or point the notebook to the completed Phase 2 Run B source package.
4. Allow the notebook to validate the package and database.
5. The notebook identifies the latest completed run, builds app-specific history-based thresholds, and generates the monitoring summary, app classifications, alerts, validation outputs, metadata, and report.

The monitoring notebook evaluates completed ingestion evidence. It does not perform another cadence collection.

### Reproduce monitoring-threshold calibration

1. Open `notebooks/Google_Play_Monitoring_Threshold_Calibration.ipynb`.
2. Run all cells in order.
3. Provide the completed Phase 2 Run B source package when requested.
4. The notebook validates required source artifacts.
5. It replays completed runs without look-ahead, compares sensitive, initial, and loose profiles, evaluates 10 controlled scenarios, and exports the recommendation and operational-response documentation.

The calibration notebook does not collect new reviews.

### Reproduce feature engineering v0

1. Open `notebooks/Google_Play_Review_Feature_Engineering_v0.ipynb` in Google Colab or a compatible Jupyter environment.
2. Run all cells in order.
3. Upload exactly one complete Phase 2 Run B follow-up ZIP when prompted, or set the `FEATURE_SOURCE_PACKAGE` environment variable to its path.
4. The notebook checks the source package manifest, file sizes, and SHA-256 values.
5. It extracts and validates the nested SQLite database.
6. Hard-failure database guards verify row counts, app count, run count, deduplication, raw/cleaned relationships, and foreign keys.
7. The notebook loads the cleaned review feature base, generates the rule-based review features, creates app-level aggregates, and exports a 30-row sample.
8. It runs all review-level and aggregate validation checks.
9. It exports the CSV, JSON, Markdown, and output-manifest deliverables.

The feature notebook uses Python, pandas, NumPy, SQLite, and the standard library. It does not require a sentiment package, external language model, or trained language detector.

## Key conclusions

1. Google Play is the strongest primary source among the tested public app-review options for this recurring-ingestion pilot.
2. The relational SQLite design successfully preserves raw reviews, cleaned text, run history, app summaries, quality flags, and duplicate prevention.
3. Six controlled Phase 2 runs completed with no app-level collection errors and no database relationship failures.
4. A blanket twice-daily schedule is not supported.
5. Once-daily collection should remain the default schedule.
6. YouTube and Instagram are possible twice-daily exceptions only when returned-window coverage is prioritized; the tests did not demonstrate a true posting-time freshness benefit.
7. The monitoring layer provides automated `healthy`, `warning`, and `failing` classifications.
8. Hard collection, database, validation, or output failures cannot be softened by otherwise normal metrics.
9. The retained median/MAD monitoring profile is a reasonable initial configuration, but it is not a final production rule because the historical baseline is still small.
10. Feature Engineering v0 preserves all 34,601 validated cleaned reviews and creates 37 transparent fields plus 10 app-level summaries.
11. Identifiers, ratings, timestamps, text length, reply presence, and deduplication guards are the strongest current features.
12. Language and keyword issue indicators are documented heuristics for screening and EDA, not ground-truth labels.
13. The rating-derived weak-sentiment baseline creates a leakage-controlled modeling-ready dataset and a transparent linear reference model.
14. Neutral-class performance remains limited, so label quality and class imbalance should be reviewed before any more complex NLP work.
15. The project is now ready for additional normal operating runs, continued monitoring, error analysis, gradual threshold recalibration, and careful design of later modeling work.

## Limitations

- Results apply to the tested apps, English/United States configuration, collection dates, and fixed 1,200-review returned window.
- Public scraper behavior and Google Play response behavior may change over time.
- A review that is new to the database is not necessarily newly posted.
- A fixed newest-review window may turn over quickly for high-activity apps.
- The observed approximately 24-hour returned-window lag is specific to the completed cadence tests and is not a universal source rule.
- App-version and developer-reply fields are naturally missing or uneven across apps.
- SQLite file-size growth is reported at run level and cannot be assigned reliably to individual apps.
- The monitoring baseline currently uses only three comparable prior runs.
- Median/MAD thresholds are initial project rules and require recalibration after more normal operating history is available.
- The short-review and low-signal thresholds are transparent project definitions, not universal measures of review usefulness.
- Identical review text does not necessarily mean duplicate review identity or invalid content.
- The language heuristic is conservative and intentionally leaves many short or unclear reviews as `undetermined`.
- Keyword issue indicators can produce both false matches and missed issues because they do not fully interpret context, negation, spelling variation, or non-English wording.
- App-level feature aggregates describe the collected database snapshot and should not be interpreted as general app-quality rankings.
- The weak-sentiment model is an exploratory linear baseline using rating-derived labels; it is not a production model and does not establish ground-truth sentiment.

## Recommended next steps

1. Continue normal ingestion with once-daily collection as the default.
2. Run monitoring and hard-failure validation after each ingestion run.
3. Review and document warnings before changing app-specific schedules.
4. Refresh the feature layer only from validated usable runs.
5. Accumulate a larger routine-run baseline and recalibrate the monitoring thresholds.
6. Use the v0 features for EDA, including rating distributions, text-length patterns, reply availability, language coverage, and issue-keyword screening.
7. Inspect false positives and false negatives before expanding the language or issue heuristics.
8. Define modeling targets and evaluation plans before beginning sentiment, topic, or issue-classification work.

## Rating-derived weak sentiment baseline v0

### Objective

This downstream exploratory layer uses the validated `review_features_v0.csv` table to derive weak sentiment labels from source ratings:

- 1–2 stars: `negative`
- 3 stars: `neutral`
- 4–5 stars: `positive`

The labels are weak labels and are not manually verified sentiment annotations.

### Leakage controls

The model excludes `score`, `rating_group`, and `low_rating_flag`. It also excludes app identity, developer-reply availability, collection dates, run IDs, app versions, and source-lag fields from model inputs. Exact normalized text groups are assigned to only one data split, and explicit written star-rating expressions are replaced with a generic token before modeling.

### Data and class distribution

- 34,601 review rows
- 10 apps
- 27,681 training rows
- 6,920 test rows
- negative: 9,948 (28.75%)
- neutral: 1,629 (4.71%)
- positive: 23,024 (66.54%)
- exact normalized-text overlap between train and test: 0

### Exploratory feature patterns

Negative reviews are longer and more likely to match issue-keyword indicators. Positive reviews are more likely to be short, low-signal, or repeated. These are descriptive patterns in the current snapshot rather than causal conclusions.

### Baseline model

A class-weighted linear support vector classifier uses TF-IDF word unigrams and bigrams plus selected deterministic review features. The model uses fixed `C=1.0` and no hyperparameter search.

| Model | Accuracy | Balanced accuracy | Macro F1 | Weighted F1 |
|---|---:|---:|---:|---:|
| Majority-class reference | 0.6655 | 0.3333 | 0.2664 | 0.5318 |
| Class-weighted LinearSVC | 0.8208 | 0.5867 | 0.5899 | 0.8196 |

The model performs substantially better than the majority-class reference on balanced accuracy and macro F1. Neutral-class performance remains limited because three-star reviews are rare and may express mixed sentiment.

### Main outputs

```text
notebooks/
└── Google_Play_Weak_Sentiment_Baseline_v0.ipynb

outputs/
├── modeling_ready_weak_sentiment_v0.csv
├── weak_sentiment_source_validation_v0.csv
├── weak_sentiment_class_distribution_v0.csv
├── weak_sentiment_feature_patterns_v0.csv
├── weak_sentiment_issue_patterns_v0.csv
├── weak_sentiment_app_distribution_v0.csv
├── weak_sentiment_model_metrics_v0.csv
├── weak_sentiment_classification_report_v0.csv
├── weak_sentiment_confusion_matrix_v0.csv
├── weak_sentiment_top_coefficients_v0.csv
├── weak_sentiment_test_predictions_sample_v0.csv
├── weak_sentiment_validation_checks_v0.csv
├── weak_sentiment_baseline_metadata_v0.json
└── weak_sentiment_output_manifest_v0.csv

reports/
├── figures/
│   ├── weak_sentiment_class_distribution_v0.png
│   ├── weak_sentiment_feature_patterns_v0.png
│   └── weak_sentiment_confusion_matrix_v0.png
├── google_play_weak_sentiment_baseline_v0_report.md
├── weak_sentiment_baseline_v0_model_card.md
└── README_weak_sentiment_baseline_v0_update.md
```

### Limitations

This is an exploratory baseline, not a production system. Ratings are weak labels, the neutral class is small, text and rating can disagree, heuristic fields can be noisy, and cross-app or future-time generalization has not been established.
