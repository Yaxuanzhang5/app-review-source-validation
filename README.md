# App Review Source Validation

This repository documents a source validation and ingestion pipeline test for public app review data.

The main goal is to evaluate whether app review data can be collected repeatedly, stored in a structured database, checked for duplicates, and tracked through run-level summaries.

The current focus is Google Play reviews using the `google-play-scraper` Python package.

---

## Latest Status

Phase 2 Day 1 and Phase 2 Day 2 have both been completed.

The current pipeline has tested:

- larger controlled ingestion across 10 Google Play apps
- 1,200 newest reviews per app
- repeated collection using the same database
- duplicate handling across runs
- new review insertion after the baseline run
- run-level and app-level summaries
- database growth tracking
- quality flag tracking
- raw-to-cleaned review linkage
- ingestion run tracking
- database relationship checks

The latest clean database is stored as a compressed file:

```text
database/google_play_reviews.sqlite.zip
```

The raw SQLite file is compressed because GitHub browser upload may fail for larger `.sqlite` files.

---

## Project Structure

```text
app-review-source-validation/
├── database/
│   └── google_play_reviews.sqlite.zip
│
├── notebooks/
│   ├── Google_Play_Controlled_Scale_Ingestion_Phase2_Day1.ipynb
│   └── Google_Play_Controlled_Scale_Ingestion_Phase2_Day2.ipynb
│
├── outputs/
│   ├── run_summaries/
│   │   ├── phase2_day1_run_summary_20260708_034445.csv
│   │   ├── phase2_day1_app_level_summary_20260708_034445.csv
│   │   ├── phase2_day1_relationship_checks_20260708_034445.csv
│   │   ├── phase2_day1_database_row_growth_20260708_034445.csv
│   │   ├── phase2_day2_run_summary_20260708_041135.csv
│   │   ├── phase2_day2_app_level_summary_20260708_041135.csv
│   │   ├── phase2_day2_relationship_checks_20260708_041135.csv
│   │   ├── phase2_day2_database_row_growth_20260708_041135.csv
│   │   ├── phase2_day1_day2_comparison_20260708_041135.csv
│   │   └── phase2_run_summary_history.csv
│   │
│   └── quality/
│       ├── phase2_day1_quality_flag_summary_20260708_034445.csv
│       └── phase2_day2_quality_flag_summary_20260708_041135.csv
│
├── reports/
│   ├── phase2_day1_controlled_scale_findings_20260708_034445.md
│   └── phase2_day2_daily_followup_findings_20260708_041135.md
│
├── requirements.txt
└── README.md
```

---

## Phase 2 Overview

Phase 2 tests whether the ingestion pipeline can move beyond a small proof of concept and support a more realistic recurring ingestion process.

The main questions are:

1. Can the pipeline collect a larger controlled batch of reviews?
2. Can the same database be reused across multiple runs?
3. Can duplicate reviews be skipped correctly?
4. Can newly appearing reviews be inserted after the baseline run?
5. Can each ingestion run be tracked clearly?
6. Can database relationships remain valid after repeated runs?
7. Can run summaries show fetched records, inserted rows, duplicates, errors, quality flags, and database growth?

---

## Source and Collection Setup

| Item | Value |
|---|---|
| Source | Google Play |
| Python package | `google-play-scraper` |
| Language | `en` |
| Country | `us` |
| Sort order | newest |
| Apps tested | 10 |
| Target reviews per app | 1,200 |
| Target records per run | 12,000 |
| Database | SQLite |
| Duplicate rule | `source + app_id + review_id` |

---

## Apps Included

| App Name | Google Play App ID |
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

## Database Tables

The Phase 2 database uses these main tables:

| Table | Purpose |
|---|---|
| `phase2_ingestion_runs` | Tracks each ingestion run, including runtime, fetched records, inserted records, duplicates, errors, quality flags, and database growth |
| `phase2_apps` | Stores app metadata and validation status |
| `phase2_reviews_raw` | Stores raw review records from Google Play |
| `phase2_reviews_cleaned` | Stores cleaned review text and cleaned fields linked to raw reviews |
| `phase2_quality_flags` | Stores quality flags at the review/run level |
| `phase2_app_run_summary` | Stores app-level metrics for each ingestion run |

---

## Phase 2 Day 1: Controlled Scale Baseline

Notebook:

```text
notebooks/Google_Play_Controlled_Scale_Ingestion_Phase2_Day1.ipynb
```

Run ID:

```text
phase2_day1_controlled_scale_20260708_034445
```

Day 1 was the baseline controlled scale run. It started from the Phase 2 database and inserted the first larger batch of Google Play reviews.

### Day 1 Results

| Metric | Result |
|---|---:|
| Apps validated | 10 |
| Records fetched | 12,000 |
| New records inserted | 12,000 |
| Duplicates skipped | 0 |
| Errors | 0 |
| Quality flags recorded | 12,633 |
| Review rows before run | 0 |
| Review rows after run | 12,000 |
| Review row growth | 12,000 |
| Database growth | 23.6602 MB |
| Run status | completed |
| Relationship checks | passed |

### Day 1 Interpretation

Day 1 confirmed that the pipeline can collect and insert a larger controlled batch across 10 apps.

The database successfully stored:

- raw reviews
- cleaned review records
- app metadata
- run tracking information
- app-level run summaries
- quality flags

The relationship checks passed after insertion, which means the raw reviews, cleaned reviews, quality flags, app records, and run tracking records were linked correctly.

---

## Phase 2 Day 2: Daily Follow-Up Run

Notebook:

```text
notebooks/Google_Play_Controlled_Scale_Ingestion_Phase2_Day2.ipynb
```

Run ID:

```text
phase2_day2_daily_followup_20260708_041135
```

Day 2 used the clean Day 1 database and repeated the same app list and target review volume.

This run tested whether the pipeline could continue from an existing database and correctly skip duplicate reviews while inserting newly appearing reviews.

### Day 2 Results

| Metric | Result |
|---|---:|
| Apps validated | 10 |
| Records fetched | 12,000 |
| New records inserted | 156 |
| Duplicates skipped | 11,844 |
| Errors | 0 |
| Quality flags recorded | 12,638 |
| Review rows before run | 12,000 |
| Review rows after run | 12,156 |
| Review row growth | 156 |
| Database growth | 4.6953 MB |
| Run status | completed |
| Relationship checks | passed |

### Day 2 App-Level New Insertions

| App | New Records Inserted |
|---|---:|
| YouTube | 33 |
| TikTok | 7 |
| Spotify | 15 |
| Instagram | 52 |
| Uber | 13 |
| DoorDash | 0 |
| Duolingo | 28 |
| Google Maps | 3 |
| Netflix | 2 |
| Reddit | 3 |
| **Total** | **156** |

### Day 2 Interpretation

Day 2 confirmed that repeated ingestion is working correctly.

The pipeline fetched another 12,000 reviews, but most of them already existed in the database from Day 1. These were skipped as duplicates. Only 156 new reviews were inserted.

This result is expected for a repeated collection test and shows that the database can continue from an existing state without duplicating existing review records.

---

## Day 1 vs Day 2 Comparison

| Metric | Day 1 Baseline | Day 2 Follow-Up |
|---|---:|---:|
| Records fetched | 12,000 | 12,000 |
| New records inserted | 12,000 | 156 |
| Duplicates skipped | 0 | 11,844 |
| Errors | 0 | 0 |
| Quality flags | 12,633 | 12,638 |
| Review rows before | 0 | 12,000 |
| Review rows after | 12,000 | 12,156 |
| Review row growth | 12,000 | 156 |
| Database growth | 23.6602 MB | 4.6953 MB |
| Status | completed | completed |
| Relationship checks | passed | passed |

### Main Finding

The Day 1 and Day 2 comparison shows that the pipeline can support recurring ingestion.

Day 1 created the controlled baseline. Day 2 reused the same database and successfully identified most fetched reviews as duplicates while inserting only newly observed reviews.

This supports the feasibility of a recurring review ingestion process.

---

## Quality Flag Summary

The quality flags were mostly informational.

For Day 2, the recorded quality flags were:

| Flag | Severity | Count |
|---|---|---:|
| missing_app_version | info | 2,067 |
| missing_developer_reply | info | 10,571 |

No major structural quality issues were observed in the Day 2 run.

There were no serious flags such as:

- missing review ID
- missing content
- missing score
- invalid score
- missing review date

This suggests the fetched review records were structurally usable for ingestion and downstream analysis.

---

## Relationship Checks

The database relationship checks passed after both Day 1 and Day 2.

The checks include:

| Check | Purpose |
|---|---|
| `raw_reviews_have_app_record` | Confirms every raw review links to an app record |
| `cleaned_reviews_link_to_raw_reviews` | Confirms every cleaned review links back to a raw review |
| `quality_flags_link_to_raw_reviews` | Confirms quality flags link to existing raw reviews |
| `quality_flags_link_to_ingestion_run` | Confirms quality flags link to an ingestion run |
| `no_duplicate_source_app_review_id` | Confirms no duplicate review records exist for the same source, app, and review ID |
| `run_reviews_link_to_ingestion_run` | Confirms run-linked reviews point to a valid ingestion run |

All checks passed in the final Day 2 database.

---

## Output Files

### Run Summaries

```text
outputs/run_summaries/phase2_day1_run_summary_20260708_034445.csv
outputs/run_summaries/phase2_day1_app_level_summary_20260708_034445.csv
outputs/run_summaries/phase2_day1_relationship_checks_20260708_034445.csv
outputs/run_summaries/phase2_day1_database_row_growth_20260708_034445.csv

outputs/run_summaries/phase2_day2_run_summary_20260708_041135.csv
outputs/run_summaries/phase2_day2_app_level_summary_20260708_041135.csv
outputs/run_summaries/phase2_day2_relationship_checks_20260708_041135.csv
outputs/run_summaries/phase2_day2_database_row_growth_20260708_041135.csv
outputs/run_summaries/phase2_day1_day2_comparison_20260708_041135.csv

outputs/run_summaries/phase2_run_summary_history.csv
```

### Quality Summaries

```text
outputs/quality/phase2_day1_quality_flag_summary_20260708_034445.csv
outputs/quality/phase2_day2_quality_flag_summary_20260708_041135.csv
```

### Findings Reports

```text
reports/phase2_day1_controlled_scale_findings_20260708_034445.md
reports/phase2_day2_daily_followup_findings_20260708_041135.md
```

### Database

```text
database/google_play_reviews.sqlite.zip
```

To use the SQLite database locally, unzip:

```text
database/google_play_reviews.sqlite.zip
```

The extracted file will be:

```text
google_play_reviews.sqlite
```

---

## How to Review the Current Results

The quickest files to review are:

1. Run history:

```text
outputs/run_summaries/phase2_run_summary_history.csv
```

2. Day 1 vs Day 2 comparison:

```text
outputs/run_summaries/phase2_day1_day2_comparison_20260708_041135.csv
```

3. Day 2 findings report:

```text
reports/phase2_day2_daily_followup_findings_20260708_041135.md
```

4. Updated compressed database:

```text
database/google_play_reviews.sqlite.zip
```

---

## Current Conclusion

The Phase 2 controlled ingestion test supports the feasibility of a recurring Google Play review ingestion pipeline.

The pipeline can:

- fetch reviews from multiple apps
- store raw and cleaned review records
- track each ingestion run
- skip duplicate reviews across repeated runs
- insert newly observed reviews
- track quality flags
- summarize app-level and run-level metrics
- measure database growth
- preserve database relationships across runs

The Day 2 follow-up run is the key validation step because it shows the pipeline can continue from the Day 1 database instead of starting over.

---

## Recommended Next Steps

The next step is to continue controlled repeated runs with the same database and app list.

Recommended next runs:

1. Phase 2 Day 2 evening run  
   Frequency label: `twice_daily_pm`

2. Phase 2 Day 3 daily follow-up run  
   Frequency label: `daily_followup`

3. Optional Phase 2 Day 3 evening run  
   Frequency label: `twice_daily_pm`

These future runs would help compare:

- once-daily vs twice-daily collection
- same-day duplicate rate
- next-day new review capture
- runtime stability across multiple runs
- app-level differences in review update frequency
- database growth over time

---

## Notes

The current database file is provided as a compressed `.zip` file because the raw SQLite database is large enough to cause issues with GitHub browser upload.

The raw SQLite file should not be uploaded separately unless using Git command line or Git LFS.

For this repo, the current database should be reviewed through:

```text
database/google_play_reviews.sqlite.zip
```
