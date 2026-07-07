# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to evaluate whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, database storage, and downstream data quality analysis.

Google Play is tested as the primary source. The iOS App Store public RSS feed is tested as a secondary source.

---

## Latest Update: Phase 2 Day 1 Controlled Scale Ingestion Test

The latest phase expands the Google Play ingestion pipeline from a small controlled database test into a larger operational test.

Phase 2 Day 1 focuses on whether the existing SQLite database pipeline can support:

- more apps beyond the original small app set
- larger review volume per app
- continued ingestion from the existing database
- duplicate handling across repeated runs
- raw and cleaned review linkage
- ingestion run tracking
- quality flag linkage
- app-level and run-level operational summaries
- database size and row count growth tracking

This phase uses the existing database:

```text
database/google_play_reviews.sqlite
```

The database was not rebuilt from scratch. The test continues from the existing project database and adds Phase 2 operational tables for larger controlled ingestion runs.

---

## Phase 2 Day 1 Test Scope

Source:

```text
Google Play
```

Collection settings:

```text
Language: en
Country: us
Sort: newest
Target reviews per app: 1,200
Apps tested: 10
```

Apps included:

```text
YouTube
TikTok
Spotify
Instagram
Uber
DoorDash
Duolingo
Google Maps
Netflix
Reddit
```

Duplicate handling rule:

```text
source + app_id + review_id
```

The Phase 2 schema also creates a hashed `review_key` for linking raw reviews, cleaned reviews, and quality flags.

---

## Phase 2 Day 1 Results

The first controlled scale run completed successfully.

| Metric | Result |
|---|---:|
| Apps validated | 10 |
| Total records fetched | 12,000 |
| New records inserted | 12,000 |
| Duplicates skipped | 0 |
| App-level errors | 0 |
| Quality flags recorded | 12,602 |
| Database size before run | 1.8320 MB |
| Database size after run | 25.5312 MB |
| Database growth | 23.6992 MB |
| Relationship checks | Passed |

The duplicate count is expected to be 0 in this first Phase 2 run because these Phase 2 tables were newly populated. Later repeated runs using the same database should start showing skipped duplicates, which will help evaluate repeated ingestion behavior.

---

## Phase 2 Database Tables

Phase 2 adds operational tables to the existing SQLite database:

```text
phase2_ingestion_runs
phase2_apps
phase2_reviews_raw
phase2_reviews_cleaned
phase2_quality_flags
phase2_app_run_summary
```

Table purposes:

| Table | Purpose |
|---|---|
| `phase2_ingestion_runs` | Tracks each ingestion run, runtime, app count, fetched records, inserted records, duplicates, errors, quality flags, and database growth |
| `phase2_apps` | Stores app metadata and validation status |
| `phase2_reviews_raw` | Stores raw Google Play review records |
| `phase2_reviews_cleaned` | Stores lightly cleaned review text linked back to raw reviews |
| `phase2_quality_flags` | Stores missing-field and data quality flags linked to reviews and ingestion runs |
| `phase2_app_run_summary` | Stores app-level metrics for each run |

---

## Phase 2 Data Quality Checks

The notebook checks the following quality conditions:

```text
missing_review_id
missing_content
empty_content
missing_score
invalid_score
missing_review_date
missing_app_version
missing_developer_reply
```

Some flags are high severity, such as missing review ID, missing content, missing score, or missing review date.

Some flags are informational, such as missing app version or missing developer reply, because these fields may naturally be unavailable for some reviews.

---

## Phase 2 Relationship Checks

After the ingestion run, the notebook validates database relationships instead of only checking row insertion.

Current relationship checks include:

```text
raw_reviews_have_app_record
cleaned_reviews_link_to_raw_reviews
quality_flags_link_to_raw_reviews
quality_flags_link_to_ingestion_run
no_duplicate_source_app_review_id
run_reviews_link_to_ingestion_run
```

All Phase 2 Day 1 relationship checks passed.

---

## Key Output Files

Latest Phase 2 Day 1 notebook:

```text
notebooks/Google_Play_Controlled_Scale_Ingestion_Phase2_Day1.ipynb
```

Updated database:

```text
database/google_play_reviews.sqlite
```

Run summary outputs:

```text
outputs/run_summaries/phase2_day1_run_summary_*.csv
outputs/run_summaries/phase2_day1_app_level_summary_*.csv
outputs/run_summaries/phase2_run_summary_history.csv
outputs/run_summaries/phase2_day1_relationship_checks_*.csv
outputs/run_summaries/phase2_day1_database_row_growth_*.csv
```

Quality summary output:

```text
outputs/quality/phase2_day1_quality_flag_summary_*.csv
```

Findings report:

```text
reports/phase2_day1_controlled_scale_findings_*.md
```

---

## How to Review the Latest Run

For a quick review, start with:

```text
reports/phase2_day1_controlled_scale_findings_*.md
```

Then check the run-level summary:

```text
outputs/run_summaries/phase2_day1_run_summary_*.csv
```

For app-level details, check:

```text
outputs/run_summaries/phase2_day1_app_level_summary_*.csv
```

For database integrity checks, check:

```text
outputs/run_summaries/phase2_day1_relationship_checks_*.csv
```

For field quality checks, check:

```text
outputs/quality/phase2_day1_quality_flag_summary_*.csv
```

---

## Earlier Project Work

Earlier phases tested whether public app review sources could support recurring ingestion.

The project previously covered:

- Google Play public review collection using `google-play-scraper`
- iOS App Store public RSS review feed testing
- public source access feasibility
- metadata availability
- pagination and batching behavior
- duplicate handling
- freshness checks
- repeated small-run ingestion testing
- SQLite database design
- raw review storage
- cleaned review linkage
- ingestion run tracking
- quality flag linkage

These earlier tests showed that Google Play is the stronger primary source for this pipeline, while the iOS App Store public RSS feed can be used as a secondary source with more limitations.

---

## Current Status

The Google Play ingestion and database pipeline is now working beyond the initial small controlled test.

Current status:

```text
Phase 1: Source validation and small database pipeline test completed
Phase 2 Day 1: Larger controlled Google Play ingestion test completed
```

The Phase 2 Day 1 run shows that the pipeline can ingest a larger controlled batch, insert records into the existing SQLite database, generate run summaries, track quality flags, and validate database relationships.

---

## Next Steps

The next step is to repeat the same controlled ingestion process using the same database and same app list across different collection times.

Recommended next runs:

```text
Phase 2 Day 1 evening: twice_daily_pm
Phase 2 Day 2 morning: daily_followup
Phase 2 Day 3 morning: daily_followup
Optional Phase 2 Day 3 evening: twice_daily_pm
```

The goal of the next repeated runs is to evaluate:

- same-day duplicate rate
- next-day new review capture
- once-daily vs twice-daily collection behavior
- runtime stability
- database size growth
- inserted rows vs skipped duplicates
- app-level failures or unstable responses
- missing field patterns across runs

This will help determine whether the pipeline can scale from a controlled demo into a more realistic recurring ingestion process.
