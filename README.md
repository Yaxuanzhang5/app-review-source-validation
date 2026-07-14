# Google Play Review Ingestion Pipeline — Phase 2 Controlled Repeated Runs and Cadence Test

## Project Overview

This repository contains the technical validation and controlled ingestion work for recurring public app-review collection.

The project began by validating public review access for Google Play and the iOS App Store. Phase 2 then focused on Google Play and expanded the work into a persistent SQLite ingestion pipeline that supports:

- repeated review collection
- raw and cleaned review storage
- deterministic duplicate prevention
- app-level and run-level metrics
- data-quality flags
- database integrity checks
- timestamp-based freshness analysis
- source returned-window analysis
- once-daily versus twice-daily cadence evaluation

The final Phase 2 database contains six completed runs using the same 10 apps and a controlled target of 1,200 reviews per app.

---

## Current Project Status

Phase 2 controlled repeated collection and cadence testing are complete.

### Final Database State

| Metric | Final Value |
|---|---:|
| Fixed apps | 10 |
| Completed Phase 2 runs | 6 |
| Raw review rows | 34,601 |
| Cleaned review rows | 34,601 |
| App-run summary rows | 60 |
| Quality-flag rows | 75,918 |
| Uncompressed database size | 84.68 MB |
| Duplicate review identities | 0 |
| Raw rows without cleaned rows | 0 |
| Cleaned rows without raw rows | 0 |
| Orphan quality flags | 0 |
| Foreign-key violations | 0 |
| SQLite integrity check | `ok` |

Final validated database:

[`database/google_play_reviews_after_runB_followup.sqlite.zip`](database/google_play_reviews_after_runB_followup.sqlite.zip)

---

## Controlled Collection Setup

The same configuration was maintained throughout the controlled Phase 2 cadence tests.

| Setting | Value |
|---|---|
| Source | Google Play |
| Python library | `google-play-scraper` |
| Collection function | `reviews()` |
| Sort order | `Sort.NEWEST` |
| Language | English (`en`) |
| Country | United States (`us`) |
| Fixed app count | 10 |
| Target per app | 1,200 reviews |
| Expected total per run | 12,000 reviews |
| Request delay | 2 seconds between app requests |
| Database | SQLite |
| Duplicate identity | `source + app_id + review_id` |

The app list, app order, source settings, review target, database schema, database continuation, and duplicate-prevention logic remained unchanged during the controlled cadence tests.

---

## Fixed App List

| App | Google Play Package ID |
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

---

## Database Design

The Phase 2 SQLite database contains six main tables.

| Table | Purpose |
|---|---|
| `phase2_apps` | Fixed app configuration and store metadata |
| `phase2_ingestion_runs` | Run-level timing, status, totals, runtime, and database growth |
| `phase2_app_run_summary` | App-level fetched, inserted, duplicate, quality, and runtime metrics |
| `phase2_reviews_raw` | Normalized source records and original review payloads |
| `phase2_reviews_cleaned` | Cleaned review text and analysis-ready fields |
| `phase2_quality_flags` | Run-scoped data-quality findings |

### Duplicate Prevention

Each review receives a deterministic `review_key` based on:

```text
source | app_id | review_id
```

The same review identity is reused across repeated runs.

When an already stored review is returned again:

- the review is not inserted a second time
- the record is counted as a skipped duplicate
- the existing raw and cleaned database relationship remains unchanged

This design supports:

- idempotent repeated ingestion
- persistent database continuation
- duplicate-rate measurement
- review lineage
- raw-to-cleaned consistency checks
- app-level and run-level comparison

---

## Phase 2 Run History

| Run | Role | Reviews Fetched | New DB Inserts | Duplicates Skipped | New Insert Rate | Duplicate Rate | Runtime | DB Row Growth |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Day 1 | Initial controlled baseline | 12,000 | 12,000 | 0 | 100.00% | 0.00% | 23.27 s | 12,000 |
| Day 2 | Early repeated follow-up | 12,000 | 156 | 11,844 | 1.30% | 98.70% | 75.80 s | 156 |
| Day 3 | Controlled repeated baseline | 12,000 | 5,659 | 6,341 | 47.16% | 52.84% | 29.27 s | 5,659 |
| Cadence Run A | First higher-frequency cadence test | 12,000 | 4,395 | 7,605 | 36.62% | 63.38% | 28.14 s | 4,395 |
| Run B First Collection | Baseline for the Run B follow-up | 12,000 | 8,638 | 3,362 | 71.98% | 28.02% | 30.76 s | 8,638 |
| Cadence Run B | Second higher-frequency cadence test | 12,000 | 3,753 | 8,247 | 31.27% | 68.73% | 30.02 s | 3,753 |

Complete six-run history:

[`outputs/phase2_complete_run_history.csv`](outputs/phase2_complete_run_history.csv)

---

## Run B First Collection Baseline

The Run B First Collection established the database and timestamp baseline used by the later Run B Follow-up Collection.

It occurred approximately 100.65 hours after Cadence Run A.

Because this interval was much longer than the controlled higher-frequency intervals, the First Collection was not treated as an independent twice-daily cadence outcome. Its purpose was to create a clean and validated starting point for the Run B follow-up.

### Run B First Collection Results

| Metric | Result |
|---|---:|
| Reviews fetched | 12,000 |
| New database inserts | 8,638 |
| Duplicates skipped | 3,362 |
| New insert rate | 71.98% |
| Duplicate rate | 28.02% |
| Reviews posted after the prior Run A boundary | 8,015 |
| Older reviews surfaced later | 623 |
| Wall-clock runtime | 30.76 s |
| Database row growth | 8,638 |
| Database size growth | 18.56 MB |
| Collection errors | 0 |

### Run B First Collection Workflow

The First Collection workflow included:

- continuation from the Cadence Run A database
- validation of the input database checkpoint
- collection of 1,200 reviews for each of the same 10 apps
- raw and cleaned review insertion
- deterministic duplicate prevention
- app-level ingestion summaries
- database integrity validation
- timestamp classification
- pre-run and post-run database snapshots
- creation of the checkpoint used by the Run B Follow-up Notebook

### Run B First Collection Notebook

[`notebooks/Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb`](notebooks/Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb)

### Run B First Collection Database

[`database/google_play_reviews_after_runB_first_collection.sqlite.zip`](database/google_play_reviews_after_runB_first_collection.sqlite.zip)

### Complete First Collection Checkpoint

This checkpoint contains the validated First Collection database and supporting output files used by the Follow-up Notebook:

[`database/phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip`](database/phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip)

### Run B First Collection Baseline Outputs

- [`outputs/phase2_cadence_runB_first_collection_app_summary.csv`](outputs/phase2_cadence_runB_first_collection_app_summary.csv)
- [`outputs/phase2_cadence_runB_first_collection_completed_run_record.csv`](outputs/phase2_cadence_runB_first_collection_completed_run_record.csv)
- [`outputs/phase2_cadence_runB_first_collection_database_validation.csv`](outputs/phase2_cadence_runB_first_collection_database_validation.csv)
- [`outputs/phase2_cadence_runB_first_collection_metadata.json`](outputs/phase2_cadence_runB_first_collection_metadata.json)
- [`outputs/phase2_cadence_runB_first_collection_pre_run_app_snapshot.csv`](outputs/phase2_cadence_runB_first_collection_pre_run_app_snapshot.csv)
- [`outputs/phase2_cadence_runB_first_collection_pre_run_snapshot.csv`](outputs/phase2_cadence_runB_first_collection_pre_run_snapshot.csv)
- [`outputs/phase2_cadence_runB_first_collection_prior_run_history.csv`](outputs/phase2_cadence_runB_first_collection_prior_run_history.csv)
- [`outputs/phase2_cadence_runB_first_collection_timestamp_audit.csv`](outputs/phase2_cadence_runB_first_collection_timestamp_audit.csv)
- [`outputs/phase2_cadence_runB_first_collection_timestamp_summary.csv`](outputs/phase2_cadence_runB_first_collection_timestamp_summary.csv)
- [`outputs/phase2_cadence_runB_first_collection_timestamp_validation.csv`](outputs/phase2_cadence_runB_first_collection_timestamp_validation.csv)
- [`outputs/phase2_cadence_runB_first_collection_checkpoint_manifest.csv`](outputs/phase2_cadence_runB_first_collection_checkpoint_manifest.csv)

---

## Controlled Cadence Tests

Two comparable higher-frequency tests were evaluated.

### Cadence Run A

- Previous collection: Day 3
- Mean app-specific interval: 17.16 hours
- Fixed apps: 10
- Target per app: 1,200 reviews

### Cadence Run B

- Previous collection: Run B First Collection
- Mean app-specific interval: 14.66 hours
- Fixed apps: 10
- Target per app: 1,200 reviews

The Run B cadence result is based on the change between the First Collection and the Follow-up Collection.

---

## Run-Level Cadence Comparison

| Metric | Cadence Run A | Cadence Run B |
|---|---:|---:|
| Mean collection interval | 17.16 h | 14.66 h |
| Reviews fetched | 12,000 | 12,000 |
| New database inserts | 4,395 | 3,753 |
| Duplicates skipped | 7,605 | 8,247 |
| New insert rate | 36.62% | 31.27% |
| Duplicate rate | 63.38% | 68.73% |
| Reviews posted between collections | 0 | 0 |
| Older reviews surfaced later | 4,395 | 3,753 |
| Posted-between rate of new inserts | 0.00% | 0.00% |
| Median source lag | 24.04 h | 24.04 h |
| Wall-clock runtime | 28.14 s | 30.02 s |
| Database row growth | 4,395 | 3,753 |
| Database size growth | 11.76 MB | 10.59 MB |
| Collection errors | 0 | 0 |

Detailed run-level comparison:

[`outputs/phase2_cadence_runA_runB_run_level_comparison.csv`](outputs/phase2_cadence_runA_runB_run_level_comparison.csv)

### New-Insert Timestamp Ranges

| Test | Earliest New-Insert Review Timestamp | Latest New-Insert Review Timestamp |
|---|---|---|
| Cadence Run A | `2026-07-04T15:23:42+00:00` | `2026-07-08T21:14:19+00:00` |
| Cadence Run B | `2026-07-13T01:56:51+00:00` | `2026-07-13T16:36:13+00:00` |

---

## Timestamp Freshness Method

A review can be new to the database without being newly posted between two collections.

For each new database insert, the analysis compared:

- the review timestamp
- the preceding app-specific `fetched_at` timestamp
- the current app-specific `fetched_at` timestamp

Each inserted review was assigned to one of four categories:

1. `posted_between_collections`
2. `older_review_surfaced_later`
3. `timestamp_after_fetch`
4. `missing_or_unusable_timestamp`

Using app-specific collection boundaries avoids treating the 10 sequential app requests as if they occurred at exactly the same time.

---

## Timestamp Freshness Result

Across Cadence Run A and Cadence Run B:

| Metric | Result |
|---|---:|
| Total new database inserts audited | 8,148 |
| Posted between collections | 0 |
| Older reviews surfaced later | 8,148 |
| Timestamp after fetch | 0 |
| Missing or unusable timestamp | 0 |

### Main Finding

All 8,148 new database inserts across the two controlled cadence tests had review timestamps at or before the preceding app-specific collection boundary.

The records were new to the database because they entered the returned review window later.

They were not newly posted during the interval between collections.

Therefore:

> `new to the database` does not mean `newly posted between runs`.

Detailed timestamp files:

- [`outputs/phase2_cadence_runA_timestamp_audit_reconstructed.csv`](outputs/phase2_cadence_runA_timestamp_audit_reconstructed.csv)
- [`outputs/phase2_cadence_runA_timestamp_summary_reconstructed.csv`](outputs/phase2_cadence_runA_timestamp_summary_reconstructed.csv)
- [`outputs/phase2_cadence_runB_followup_timestamp_audit.csv`](outputs/phase2_cadence_runB_followup_timestamp_audit.csv)
- [`outputs/phase2_cadence_runB_followup_timestamp_summary.csv`](outputs/phase2_cadence_runB_followup_timestamp_summary.csv)

---

## Returned-Window Lag

The newest returned review remained approximately 24 hours behind the collection time in both controlled cadence tests.

| Test | Median Lag Between Collection Time and Newest Returned Review |
|---|---:|
| Cadence Run A | 24.04 h |
| Cadence Run B | 24.04 h |

Run B source-freshness diagnostics found:

- all 10 returned review windows moved forward
- median returned-window advance was 14.72 hours
- mean collection interval was 14.66 hours
- all 10 latest returned timestamps belonged to newly inserted reviews
- follow-up source lag ranged from approximately 24.01 to 24.49 hours
- all 10 apps showed at least 20 hours of source lag

This supports the interpretation that the returned review window moved forward with time while remaining approximately one day behind the live collection timestamp.

This approximately 24-hour lag was a consistent observation in these controlled runs. It should not be treated as a universal Google Play rule.

Detailed source-freshness output:

[`outputs/phase2_cadence_runB_followup_source_freshness_diagnostic.csv`](outputs/phase2_cadence_runB_followup_source_freshness_diagnostic.csv)

---

## Cadence Run A App-Level Results

| App | New DB Inserts | Duplicate Rate | App Runtime | New-Insert Timestamp Range | Posted Between |
|---|---:|---:|---:|---|---:|
| YouTube | 1,199 | 0.08% | 1.22 s | `2026-07-08T10:17:11+00:00` to `2026-07-08T21:13:22+00:00` | 0 |
| TikTok | 622 | 48.17% | 0.68 s | `2026-07-08T04:08:06+00:00` to `2026-07-08T21:14:15+00:00` | 0 |
| Spotify | 580 | 51.67% | 0.74 s | `2026-07-08T04:06:13+00:00` to `2026-07-08T21:14:19+00:00` | 0 |
| Instagram | 1,198 | 0.17% | 1.02 s | `2026-07-08T11:26:23+00:00` to `2026-07-08T21:12:32+00:00` | 0 |
| Uber | 317 | 73.58% | 0.98 s | `2026-07-08T04:09:18+00:00` to `2026-07-08T21:12:10+00:00` | 0 |
| DoorDash | 73 | 93.92% | 0.57 s | `2026-07-08T04:54:25+00:00` to `2026-07-08T21:03:08+00:00` | 0 |
| Duolingo | 6 | 99.50% | 0.78 s | `2026-07-08T04:17:19+00:00` to `2026-07-08T15:57:17+00:00` | 0 |
| Google Maps | 184 | 84.67% | 0.65 s | `2026-07-04T15:23:42+00:00` to `2026-07-08T21:14:19+00:00` | 0 |
| Netflix | 123 | 89.75% | 0.72 s | `2026-07-08T04:08:00+00:00` to `2026-07-08T21:01:32+00:00` | 0 |
| Reddit | 93 | 92.25% | 0.68 s | `2026-07-08T04:15:59+00:00` to `2026-07-08T20:43:50+00:00` | 0 |

---

## Cadence Run B App-Level Results

| App | New DB Inserts | Duplicate Rate | App Runtime | New-Insert Timestamp Range | Posted Between |
|---|---:|---:|---:|---|---:|
| YouTube | 994 | 17.17% | 1.93 s | `2026-07-13T01:59:02+00:00` to `2026-07-13T16:35:07+00:00` | 0 |
| TikTok | 406 | 66.17% | 0.79 s | `2026-07-13T01:59:51+00:00` to `2026-07-13T16:34:23+00:00` | 0 |
| Spotify | 456 | 62.00% | 0.77 s | `2026-07-13T01:56:51+00:00` to `2026-07-13T16:35:05+00:00` | 0 |
| Instagram | 1,196 | 0.33% | 0.85 s | `2026-07-13T08:02:32+00:00` to `2026-07-13T16:36:13+00:00` | 0 |
| Uber | 309 | 74.25% | 0.78 s | `2026-07-13T02:01:50+00:00` to `2026-07-13T16:34:04+00:00` | 0 |
| DoorDash | 25 | 97.92% | 0.93 s | `2026-07-13T01:58:41+00:00` to `2026-07-13T16:32:29+00:00` | 0 |
| Duolingo | 3 | 99.75% | 0.97 s | `2026-07-13T08:45:54+00:00` to `2026-07-13T16:07:35+00:00` | 0 |
| Google Maps | 151 | 87.42% | 0.84 s | `2026-07-13T02:06:35+00:00` to `2026-07-13T16:34:26+00:00` | 0 |
| Netflix | 152 | 87.33% | 0.86 s | `2026-07-13T01:58:20+00:00` to `2026-07-13T16:31:09+00:00` | 0 |
| Reddit | 61 | 94.92% | 0.74 s | `2026-07-13T02:03:14+00:00` to `2026-07-13T16:32:15+00:00` | 0 |

Complete app-level comparison:

[`outputs/phase2_cadence_runA_runB_app_level_recommendations.csv`](outputs/phase2_cadence_runA_runB_app_level_recommendations.csv)

---

## App-Level Cadence Decision Rules

The following project-specific operating rules were used for the tested 1,200-review returned window.

### Twice-Daily Coverage Candidate

An app is classified as a twice-daily coverage candidate when at least 80% of the returned batch is new to the database in both controlled cadence tests.

### Once-Daily Candidate

An app is classified as a once-daily candidate when at least 70% of the returned batch is duplicate in both controlled cadence tests.

### Monitor Before Changing Cadence

Apps that fall between the two patterns remain under observation.

These thresholds are project-specific operating rules for this controlled experiment. They are not universal Google Play thresholds.

---

## Final App-Level Recommendation

| App | Run A New Insert Rate | Run B New Insert Rate | Timestamp Freshness Benefit | Recommendation |
|---|---:|---:|---|---|
| YouTube | 99.92% | 82.83% | Not demonstrated | Twice-daily candidate for returned-window coverage |
| TikTok | 51.83% | 33.83% | Not demonstrated | Monitor before changing cadence |
| Spotify | 48.33% | 38.00% | Not demonstrated | Monitor before changing cadence |
| Instagram | 99.83% | 99.67% | Not demonstrated | Twice-daily candidate for returned-window coverage |
| Uber | 26.42% | 25.75% | Not demonstrated | Once-daily candidate |
| DoorDash | 6.08% | 2.08% | Not demonstrated | Once-daily candidate |
| Duolingo | 0.50% | 0.25% | Not demonstrated | Once-daily candidate |
| Google Maps | 15.33% | 12.58% | Not demonstrated | Once-daily candidate |
| Netflix | 10.25% | 12.67% | Not demonstrated | Once-daily candidate |
| Reddit | 7.75% | 5.08% | Not demonstrated | Once-daily candidate |

---

## Twice-Daily Coverage Candidates

### YouTube

- Run A new insert rate: 99.92%
- Run B new insert rate: 82.83%
- Run A duplicate rate: 0.08%
- Run B duplicate rate: 17.17%
- Timestamp-verified reviews posted between collections: 0 in both tests

YouTube showed high returned-window turnover in both cadence tests.

The fixed 1,200-review returned batch was close to saturation, creating a possible coverage risk under a longer collection interval.

### Instagram

- Run A new insert rate: 99.83%
- Run B new insert rate: 99.67%
- Run A duplicate rate: 0.17%
- Run B duplicate rate: 0.33%
- Timestamp-verified reviews posted between collections: 0 in both tests

Instagram showed almost complete returned-window replacement in both cadence tests.

This creates the strongest returned-window coverage case for a possible twice-daily exception.

### Important Limitation

YouTube and Instagram are twice-daily candidates only for returned-window coverage.

No posting-time freshness benefit was demonstrated for either app.

---

## Once-Daily Candidates

The following apps were at least 70% duplicate in both controlled cadence tests:

- Uber
- DoorDash
- Duolingo
- Google Maps
- Netflix
- Reddit

These apps also produced zero timestamp-verified reviews posted between collections.

Under the current 1,200-review setup, the results support keeping these apps on once-daily collection.

---

## Monitor Before Changing Cadence

The following apps showed moderate returned-window turnover:

- TikTok
- Spotify

Their current results do not support a clear app-specific twice-daily exception.

Additional controlled observations would be needed before changing their cadence.

---

## Overall Cadence Recommendation

A blanket twice-daily schedule is not supported for all 10 apps.

The controlled results support:

- once-daily collection as the default
- possible twice-daily exceptions for YouTube and Instagram when returned-window coverage is important
- continued monitoring for TikTok and Spotify
- once-daily collection for Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit

The recommendation separates two different operational questions:

1. **Posting-time freshness:** whether the collection captures reviews posted between two runs
2. **Returned-window coverage:** whether a fixed 1,200-review returned window changes quickly enough to create a missed-coverage risk

No posting-time freshness benefit was demonstrated.

YouTube and Instagram still showed a possible returned-window coverage benefit.

---

## Runtime Measurement

Run-level runtime and app-level runtime use different definitions.

### Run-Level Runtime

Run-level runtime is the wall-clock collection time and includes the fixed delay between app requests.

### App-Level Runtime

App-level runtime is the processing time recorded for the individual app request.

The Run B runtime records were normalized so that the database run-level `runtime_seconds` field uses wall-clock collection runtime.

| Run | Processing Runtime | Wall-Clock Runtime | Database Runtime |
|---|---:|---:|---:|
| Run B First Collection | 10.09 s | 30.76 s | 30.76 s |
| Run B Follow-up | 9.46 s | 30.02 s | 30.02 s |

Runtime output:

[`outputs/phase2_cadence_runB_followup_runtime_metrics.csv`](outputs/phase2_cadence_runB_followup_runtime_metrics.csv)

---

## Data Validation

The final workflow validates:

- fixed app count
- fixed review target
- run-level totals
- app-level totals
- new insert plus duplicate reconciliation
- raw and cleaned one-to-one relationships
- database row growth
- duplicate review identities
- missing review IDs
- orphan raw records
- orphan cleaned records
- orphan quality flags
- app-specific collection boundaries
- timestamp classification totals
- source freshness
- runtime consistency
- SQLite foreign keys
- SQLite integrity
- final database row counts
- completed run count
- app-summary row count
- exported file sizes
- exported SHA-256 values
- final report completeness
- final ZIP contents

The final package validations completed without failures.

### Key Validation Files

- [`outputs/phase2_cadence_runA_runB_comparison_validation.csv`](outputs/phase2_cadence_runA_runB_comparison_validation.csv)
- [`outputs/phase2_cadence_runA_runB_final_report_validation.csv`](outputs/phase2_cadence_runA_runB_final_report_validation.csv)
- [`outputs/phase2_cadence_runA_timestamp_validation.csv`](outputs/phase2_cadence_runA_timestamp_validation.csv)
- [`outputs/phase2_cadence_runB_first_collection_database_validation.csv`](outputs/phase2_cadence_runB_first_collection_database_validation.csv)
- [`outputs/phase2_cadence_runB_first_collection_timestamp_validation.csv`](outputs/phase2_cadence_runB_first_collection_timestamp_validation.csv)
- [`outputs/phase2_cadence_runB_followup_database_validation.csv`](outputs/phase2_cadence_runB_followup_database_validation.csv)
- [`outputs/phase2_cadence_runB_followup_final_database_validation.csv`](outputs/phase2_cadence_runB_followup_final_database_validation.csv)
- [`outputs/phase2_cadence_runB_followup_timestamp_validation.csv`](outputs/phase2_cadence_runB_followup_timestamp_validation.csv)
- [`outputs/phase2_cadence_runB_followup_source_freshness_validation.csv`](outputs/phase2_cadence_runB_followup_source_freshness_validation.csv)
- [`outputs/phase2_cadence_runB_followup_runtime_validation.csv`](outputs/phase2_cadence_runB_followup_runtime_validation.csv)
- [`outputs/final_package_manifest.csv`](outputs/final_package_manifest.csv)

---

## Final Package Validation

The completed final package contains:

- final database
- final report
- run-level comparison
- app-level recommendations
- Run A timestamp reconstruction
- Run B First Collection baseline records
- Run B Follow-up timestamp audit
- source-freshness diagnostic
- runtime metrics
- metadata
- complete run history
- validation outputs
- SHA-256 manifest

The final report completeness validation confirms that the report includes:

- controlled setup
- Run B First Collection baseline
- run-level comparison
- Run A app-level results
- Run B app-level results
- app-level runtime
- timestamp ranges
- database growth notes
- all 10 apps
- final recommendations
- measurement notes

---

## Key Repository Files

### Run B First Collection Notebook

[`notebooks/Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb`](notebooks/Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb)

This notebook established the validated Run B baseline and generated the checkpoint used by the follow-up collection.

### Run B Follow-up Notebook

[`notebooks/Google_Play_Phase2_Cadence_Test_RunB_Followup_Collection.ipynb`](notebooks/Google_Play_Phase2_Cadence_Test_RunB_Followup_Collection.ipynb)

The latest notebook includes:

- checkpoint upload and validation
- database continuation
- follow-up run creation
- controlled review collection
- app-level ingestion metrics
- post-run database validation
- app-specific timestamp audit
- source-freshness diagnostics
- runtime normalization
- Cadence Run A timestamp reconstruction
- Run A versus Run B comparison
- app-level recommendations
- final report generation
- final package generation
- manifest validation

### Cadence Run A Notebook

[`notebooks/Google_Play_Phase2_Cadence_Test_RunA.ipynb`](notebooks/Google_Play_Phase2_Cadence_Test_RunA.ipynb)

### Final Report

[`reports/phase2_cadence_runA_runB_final_report.md`](reports/phase2_cadence_runA_runB_final_report.md)

### Run B Database Checkpoints

Run B First Collection database:

[`database/google_play_reviews_after_runB_first_collection.sqlite.zip`](database/google_play_reviews_after_runB_first_collection.sqlite.zip)

Complete First Collection checkpoint used by the Follow-up Notebook:

[`database/phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip`](database/phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip)

Final database after the Run B Follow-up Collection:

[`database/google_play_reviews_after_runB_followup.sqlite.zip`](database/google_play_reviews_after_runB_followup.sqlite.zip)

### Main Final Outputs

- [`outputs/phase2_cadence_runA_runB_run_level_comparison.csv`](outputs/phase2_cadence_runA_runB_run_level_comparison.csv)
- [`outputs/phase2_cadence_runA_runB_app_level_recommendations.csv`](outputs/phase2_cadence_runA_runB_app_level_recommendations.csv)
- [`outputs/phase2_cadence_runB_followup_app_summary.csv`](outputs/phase2_cadence_runB_followup_app_summary.csv)
- [`outputs/phase2_cadence_runB_followup_timestamp_audit.csv`](outputs/phase2_cadence_runB_followup_timestamp_audit.csv)
- [`outputs/phase2_cadence_runB_followup_timestamp_summary.csv`](outputs/phase2_cadence_runB_followup_timestamp_summary.csv)
- [`outputs/phase2_cadence_runB_followup_source_freshness_diagnostic.csv`](outputs/phase2_cadence_runB_followup_source_freshness_diagnostic.csv)
- [`outputs/phase2_cadence_runB_followup_runtime_metrics.csv`](outputs/phase2_cadence_runB_followup_runtime_metrics.csv)
- [`outputs/phase2_cadence_runB_followup_metadata.json`](outputs/phase2_cadence_runB_followup_metadata.json)
- [`outputs/phase2_complete_run_history.csv`](outputs/phase2_complete_run_history.csv)
- [`outputs/final_package_manifest.csv`](outputs/final_package_manifest.csv)

---

## Repository Structure

```text
app-review-source-validation/
├── data/
│   └── source-validation and sample data files
├── database/
│   ├── google_play_reviews.sqlite
│   ├── google_play_reviews.sqlite.zip
│   ├── google_play_reviews_after_day3.sqlite.zip
│   ├── google_play_reviews_after_cadence_runA.sqlite.zip
│   ├── google_play_reviews_after_runB_first_collection.sqlite.zip
│   ├── phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip
│   └── google_play_reviews_after_runB_followup.sqlite.zip
├── database_design/
│   └── SQLite schema and database design files
├── notebooks/
│   ├── Phase 1 source-validation notebooks
│   ├── Phase 2 Day 1 notebook
│   ├── Phase 2 Day 2 notebook
│   ├── Phase 2 Day 3 notebook
│   ├── Google_Play_Phase2_Cadence_Test_RunA.ipynb
│   ├── Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb
│   └── Google_Play_Phase2_Cadence_Test_RunB_Followup_Collection.ipynb
├── outputs/
│   ├── Phase 1 validation outputs
│   ├── Phase 2 repeated-run outputs
│   ├── Run A cadence outputs
│   ├── Run B First Collection baseline outputs
│   ├── Run B Follow-up outputs
│   ├── timestamp audits
│   ├── source-freshness diagnostics
│   ├── runtime metrics
│   ├── validation files
│   ├── phase2_complete_run_history.csv
│   └── final_package_manifest.csv
├── reports/
│   ├── earlier run findings
│   └── phase2_cadence_runA_runB_final_report.md
├── .gitignore
├── README.md
└── requirements.txt
```

---

## Run B Reproduction Order

The completed Run B workflow should be read in this order:

1. Open `Google_Play_Phase2_Cadence_Test_RunB_First_Collection.ipynb`.
2. Review the First Collection baseline outputs.
3. Use `phase2_cadence_runB_first_collection_checkpoint_20260714_020137_utc.zip` as the validated checkpoint.
4. Open `Google_Play_Phase2_Cadence_Test_RunB_Followup_Collection.ipynb`.
5. Review the timestamp and source-freshness analysis.
6. Review the Run A versus Run B comparison.
7. Review the final app-level cadence recommendation.

Workflow:

```text
Cadence Run A database
        ↓
Run B First Collection Notebook
        ↓
First Collection database and baseline outputs
        ↓
Validated First Collection checkpoint
        ↓
Run B Follow-up Notebook
        ↓
Final database and timestamp audit
        ↓
Run A versus Run B comparison
        ↓
Final cadence recommendation
```

---

## Running the Notebooks

Install the required Python packages:

```bash
pip install -r requirements.txt
```

The notebooks were developed and executed in Google Colab.

For a new controlled collection:

1. Open the required notebook in Google Colab.
2. Run the dependency and configuration cells.
3. Upload the database checkpoint requested by the notebook.
4. Validate the checkpoint before collection.
5. Confirm the fixed app list and 1,200-review target.
6. Create the run-level database record.
7. Run the collection cell only once.
8. Complete the database validation.
9. Complete the timestamp audit.
10. Complete the source-freshness analysis.
11. Export the database, CSV files, metadata, report, and manifest.
12. Verify every validation check before publishing results.

The First Collection Notebook records how the Run B baseline checkpoint was created.

The Follow-up Notebook records the exact checkpoint and controlled configuration used for the completed Run B cadence test.

---

## Measurement Notes

- Run-level runtime is wall-clock collection time and includes the fixed delay between app requests.
- App-level runtime is the processing time recorded for each app request.
- New database inserts represent review identities that were not previously stored.
- New database inserts are not automatically treated as newly posted reviews.
- Posting-time freshness is determined from review timestamps and app-specific collection boundaries.
- The returned review window can move forward even when the newest returned review remains behind the live collection timestamp.
- Database size growth is reported only at run level because SQLite file-page growth cannot be reliably assigned to individual apps.
- The approximately 24-hour returned-window lag is an observed result from the controlled tests, not a universal Google Play rule.
- The cadence recommendations apply to the tested apps, source settings, 1,200-review returned window, and recorded collection periods.
- The First Collection was used as the Run B baseline because its interval from Cadence Run A was substantially longer than the controlled follow-up interval.
- The Run B cadence result is based on the interval between the First Collection and the Follow-up Collection.

---

## Final Conclusion

The ingestion pipeline successfully completed six persistent Phase 2 runs without creating duplicate review identities or breaking database relationships.

Repeated collection is technically feasible, but the results do not support using the same cadence for every app.

The two controlled higher-frequency tests found:

- 8,148 new database inserts
- 0 reviews timestamp-verified as posted between collections
- 8,148 older reviews that surfaced later
- approximately 24.04 hours of median returned-window lag in both tests
- zero collection errors
- zero duplicate review identities
- zero broken raw-to-cleaned relationships

YouTube and Instagram showed consistently high returned-window turnover. Their fixed 1,200-review returned windows may create a coverage risk under a longer collection interval.

Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit remained duplicate-heavy in both cadence tests.

TikTok and Spotify showed moderate turnover and require additional observation.

The final operating recommendation is:

- use once-daily collection as the default
- consider twice-daily collection for YouTube and Instagram when returned-window coverage is important
- continue monitoring TikTok and Spotify
- retain once-daily collection for Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit

This recommendation separates posting-time freshness from returned-window coverage and is based on the validated database, First Collection baseline, Follow-up Collection results, timestamp audits, source-freshness diagnostics, and app-level cadence comparison stored in this repository.
