# Google Play Review Ingestion Pipeline — Phase 2 Controlled Repeated Runs and Cadence Test

## Project Overview

This repository contains the Phase 2 Google Play review ingestion pipeline.

The goal of this phase is to move beyond a small demo and test whether the pipeline can behave like a real recurring ingestion system. The pipeline collects Google Play reviews, stores them in SQLite, avoids duplicate review inserts, tracks app-level and run-level results, and produces consistent summary outputs for repeated evaluation.

The current Phase 2 work includes:

1. Controlled repeated runs using the same 10 apps and the same 1,200-review target.
2. A cadence test comparing the once-daily-style baseline with a same-day second collection run.
3. Consistent run summaries, app-level summaries, quality flags, schema snapshots, findings reports, and compressed database snapshots.

## Current Status

Phase 2 has completed:

- Day 1 controlled baseline run
- Day 2 controlled repeated run
- Day 3 controlled repeated run
- Cadence Test Run A: same-day second collection / twice-daily test

The latest cadence test continues from the fixed Day 3 SQLite database and keeps the same setup:

- same 10 apps
- same 1,200-review target per app
- same Google Play source
- same language and country setting
- same SQLite continuation logic
- same duplicate prevention logic

## Apps Included

The same 10 apps were used across the Phase 2 controlled repeated runs and Cadence Run A:

| App | Google Play App ID |
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

## Repository Structure

```text
.
├── README.md
├── notebooks/
│   ├── Google_Play_Controlled_Scale_Ingestion_Phase2_Day1.ipynb
│   ├── Google_Play_Controlled_Scale_Ingestion_Phase2_Day2.ipynb
│   ├── Google_Play_Controlled_Scale_Ingestion_Phase2_Day3.ipynb
│   └── Google_Play_Phase2_Cadence_Test_RunA.ipynb
└── outputs/
    ├── phase2_day3_run_summary.csv
    ├── phase2_day3_app_level_summary.csv
    ├── phase2_day3_quality_flags.csv
    ├── phase2_repeated_run_history_through_day3.csv
    ├── phase2_app_level_history_through_day3.csv
    ├── phase2_day3_app_new_insert_ranking.csv
    ├── phase2_day3_sample_new_reviews.csv
    ├── phase2_day3_database_schema_snapshot.csv
    ├── phase2_day3_findings_report.md
    ├── phase2_day3_output_file_manifest.csv
    ├── google_play_reviews_after_day3.sqlite.zip
    ├── phase2_cadence_runA_run_summary.csv
    ├── phase2_cadence_runA_app_level_summary.csv
    ├── phase2_cadence_runA_quality_flags.csv
    ├── phase2_cadence_comparison_through_runA.csv
    ├── phase2_cadence_app_comparison_through_runA.csv
    ├── phase2_cadence_runA_app_new_insert_ranking.csv
    ├── phase2_cadence_runA_sample_new_reviews.csv
    ├── phase2_cadence_runA_database_schema_snapshot.csv
    ├── phase2_cadence_operating_assumption_findings.md
    ├── phase2_cadence_runA_output_file_manifest.csv
    └── google_play_reviews_after_cadence_runA.sqlite.zip
