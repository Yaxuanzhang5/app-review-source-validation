# Phase 2 Day 3 Controlled Repeated Run Findings

## Purpose

Day 3 continues the controlled repeated-run setup from Phase 2 Day 1 and Day 2.

The setup was intentionally kept the same so the results remain comparable before moving into cadence testing.

## Run Setup

- Run label: `phase2_day3_controlled_repeated_run`
- Run ID: `phase2_day3_controlled_repeated_run_20260709_040118`
- Phase: Phase 2
- Source: Google Play
- Language / country: `en` / `us`
- Sort method: newest reviews
- Apps: 10
- Target reviews per app: 1,200
- Database: continued from the existing Day 2 SQLite database

## Overall Day 3 Results

| Metric | Value |
|---|---:|
| Total fetched records | 12,000 |
| New records inserted | 5,659 |
| Duplicates skipped | 6,341 |
| Duplicate rate | 52.84% |
| New insert rate | 47.16% |
| Runtime seconds | 29.27 |
| Runtime minutes | 0.49 |
| Raw review rows before | 12,156 |
| Raw review rows after | 17,815 |
| Raw review row growth | 5,659 |
| Database size before | 30.19 MB |
| Database size after | 43.76 MB |
| Database size growth | 13.57 MB |
| Errors | 0 |
| Quality flags | 12,696 |

## Day 3 App-Level Results

| app_name    |   records_fetched |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   runtime_seconds |   quality_flag_count | max_review_date           |
|:------------|------------------:|-----------------------:|---------------------:|-----------------:|------------------:|---------------------:|:--------------------------|
| YouTube     |              1200 |                   1200 |                    0 |         0        |          1.23618  |                 1223 | 2026-07-08T04:03:49+00:00 |
| Instagram   |              1200 |                   1200 |                    0 |         0        |          0.921305 |                 1569 | 2026-07-08T04:04:39+00:00 |
| Duolingo    |              1200 |                    856 |                  344 |         0.286667 |          1.30567  |                 1294 | 2026-07-08T02:31:26+00:00 |
| Spotify     |              1200 |                    723 |                  477 |         0.3975   |          0.808337 |                 1258 | 2026-07-08T04:04:15+00:00 |
| TikTok      |              1200 |                    636 |                  564 |         0.47     |          0.835629 |                  649 | 2026-07-08T04:02:20+00:00 |
| Uber        |              1200 |                    402 |                  798 |         0.665    |          0.699476 |                 1375 | 2026-07-08T04:02:44+00:00 |
| Google Maps |              1200 |                    231 |                  969 |         0.8075   |          1.41416  |                  970 | 2026-07-08T04:04:13+00:00 |
| Netflix     |              1200 |                    146 |                 1054 |         0.878333 |          0.660416 |                 1575 | 2026-07-08T03:57:40+00:00 |
| Reddit      |              1200 |                    135 |                 1065 |         0.8875   |          0.61127  |                 1457 | 2026-07-08T03:32:19+00:00 |
| DoorDash    |              1200 |                    130 |                 1070 |         0.891667 |          0.711403 |                 1326 | 2026-07-08T03:59:09+00:00 |

## Apps With the Most New Inserts

| app_name   |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   new_insert_rate | max_review_date           |
|:-----------|-----------------------:|---------------------:|-----------------:|------------------:|:--------------------------|
| YouTube    |                   1200 |                    0 |         0        |          1        | 2026-07-08T04:03:49+00:00 |
| Instagram  |                   1200 |                    0 |         0        |          1        | 2026-07-08T04:04:39+00:00 |
| Duolingo   |                    856 |                  344 |         0.286667 |          0.713333 | 2026-07-08T02:31:26+00:00 |
| Spotify    |                    723 |                  477 |         0.3975   |          0.6025   | 2026-07-08T04:04:15+00:00 |
| TikTok     |                    636 |                  564 |         0.47     |          0.53     | 2026-07-08T04:02:20+00:00 |

## Apps With the Highest Duplicate Rate

| app_name    |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   quality_flag_count |
|:------------|-----------------------:|---------------------:|-----------------:|---------------------:|
| DoorDash    |                    130 |                 1070 |         0.891667 |                 1326 |
| Reddit      |                    135 |                 1065 |         0.8875   |                 1457 |
| Netflix     |                    146 |                 1054 |         0.878333 |                 1575 |
| Google Maps |                    231 |                  969 |         0.8075   |                  970 |
| Uber        |                    402 |                  798 |         0.665    |                 1375 |

## Quality Flag Summary

| flag_name               | flag_severity   |   flag_count |
|:------------------------|:----------------|-------------:|
| missing_developer_reply | info            |        10614 |
| missing_app_version     | info            |         2082 |

## Interpretation

Day 3 continued from the existing Day 2 database and used the same 10 apps with the same 1,200-review target per app.

The main evaluation points are duplicate rate, new review capture, runtime, app-level behavior, quality flags, and database growth. These results should be compared with Day 1 and Day 2 before changing the app list, review target, or collection cadence.

## Next Step

The next step is to finish the controlled repeated-run baseline first. After the baseline is stable, the pipeline can move into cadence testing, such as once-daily versus twice-daily collection.
