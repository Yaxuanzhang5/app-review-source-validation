# Phase 2 Cadence Test Run A Findings

## Purpose

This run starts the operating-assumption testing after the Day 1-Day 3 controlled repeated-run baseline.

The test compares the existing once-daily controlled baseline with a same-day second collection run.

## Run Setup

- Run label: `phase2_cadence_runA_twice_daily_test`
- Run ID: `phase2_cadence_runA_twice_daily_test_20260709_210858`
- Frequency label: `twice_daily_same_day_second_run`
- Source: Google Play
- Language / country: `en` / `us`
- Apps: 10
- Target reviews per app: 1,200
- Database: continued from the fixed Day 3 Phase 2 SQLite database

## Overall Run A Results

| Metric | Value |
|---|---:|
| Total fetched records | 12,000 |
| New records inserted | 4,395 |
| Duplicates skipped | 7,605 |
| Duplicate rate | 63.38% |
| New insert rate | 36.62% |
| Runtime seconds | 28.14 |
| Runtime minutes | 0.47 |
| Raw review rows before | 17,815 |
| Raw review rows after | 22,210 |
| Raw review row growth | 4,395 |
| Database size before | 43.76 MB |
| Database size after | 55.52 MB |
| Database size growth | 11.76 MB |
| Errors | 0 |
| Quality flags | 12,721 |

## Once-Daily Baseline vs. Twice-Daily Run A

| Metric | Latest once-daily baseline | Twice-daily Run A |
|---|---:|---:|
| New records inserted | 5659 | 4,395 |
| Duplicate rate | 52.84% | 63.38% |
| New insert rate | 47.16% | 36.62% |
| Runtime seconds | 29.269240617752075 | 28.14 |
| Review row growth | 5659 | 4,395 |

## Run A App-Level Results

| app_name    |   records_fetched |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   new_insert_rate |   runtime_seconds |   quality_flag_count | max_review_date           |
|:------------|------------------:|-----------------------:|---------------------:|-----------------:|------------------:|------------------:|---------------------:|:--------------------------|
| YouTube     |              1200 |                   1199 |                    1 |      0.000833333 |         0.999167  |          1.2182   |                 1236 | 2026-07-08T21:13:22+00:00 |
| Instagram   |              1200 |                   1198 |                    2 |      0.00166667  |         0.998333  |          1.02099  |                 1590 | 2026-07-08T21:12:32+00:00 |
| TikTok      |              1200 |                    622 |                  578 |      0.481667    |         0.518333  |          0.683194 |                  649 | 2026-07-08T21:14:15+00:00 |
| Spotify     |              1200 |                    580 |                  620 |      0.516667    |         0.483333  |          0.741731 |                 1280 | 2026-07-08T21:14:19+00:00 |
| Uber        |              1200 |                    317 |                  883 |      0.735833    |         0.264167  |          0.980962 |                 1368 | 2026-07-08T21:12:10+00:00 |
| Google Maps |              1200 |                    184 |                 1016 |      0.846667    |         0.153333  |          0.652907 |                  964 | 2026-07-08T21:14:19+00:00 |
| Netflix     |              1200 |                    123 |                 1077 |      0.8975      |         0.1025    |          0.715119 |                 1555 | 2026-07-08T21:01:32+00:00 |
| Reddit      |              1200 |                     93 |                 1107 |      0.9225      |         0.0775    |          0.680379 |                 1452 | 2026-07-08T20:43:50+00:00 |
| DoorDash    |              1200 |                     73 |                 1127 |      0.939167    |         0.0608333 |          0.570115 |                 1333 | 2026-07-08T21:03:08+00:00 |
| Duolingo    |              1200 |                      6 |                 1194 |      0.995       |         0.005     |          0.777184 |                 1294 | 2026-07-08T15:57:17+00:00 |

## Apps With the Most New Inserts

| app_name   |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   new_insert_rate | max_review_date           |
|:-----------|-----------------------:|---------------------:|-----------------:|------------------:|:--------------------------|
| YouTube    |                   1199 |                    1 |      0.000833333 |          0.999167 | 2026-07-08T21:13:22+00:00 |
| Instagram  |                   1198 |                    2 |      0.00166667  |          0.998333 | 2026-07-08T21:12:32+00:00 |
| TikTok     |                    622 |                  578 |      0.481667    |          0.518333 | 2026-07-08T21:14:15+00:00 |
| Spotify    |                    580 |                  620 |      0.516667    |          0.483333 | 2026-07-08T21:14:19+00:00 |
| Uber       |                    317 |                  883 |      0.735833    |          0.264167 | 2026-07-08T21:12:10+00:00 |

## Apps With the Highest Duplicate Rate

| app_name    |   new_records_inserted |   duplicates_skipped |   duplicate_rate |   quality_flag_count |
|:------------|-----------------------:|---------------------:|-----------------:|---------------------:|
| Duolingo    |                      6 |                 1194 |         0.995    |                 1294 |
| DoorDash    |                     73 |                 1127 |         0.939167 |                 1333 |
| Reddit      |                     93 |                 1107 |         0.9225   |                 1452 |
| Netflix     |                    123 |                 1077 |         0.8975   |                 1555 |
| Google Maps |                    184 |                 1016 |         0.846667 |                  964 |

## Slowest Apps

| app_name   |   runtime_seconds |   records_fetched |   new_records_inserted |   duplicates_skipped |   quality_flag_count |
|:-----------|------------------:|------------------:|-----------------------:|---------------------:|---------------------:|
| YouTube    |          1.2182   |              1200 |                   1199 |                    1 |                 1236 |
| Instagram  |          1.02099  |              1200 |                   1198 |                    2 |                 1590 |
| Uber       |          0.980962 |              1200 |                    317 |                  883 |                 1368 |
| Duolingo   |          0.777184 |              1200 |                      6 |                 1194 |                 1294 |
| Spotify    |          0.741731 |              1200 |                    580 |                  620 |                 1280 |

## Quality Flag Summary

| flag_name               | flag_severity   |   flag_count |
|:------------------------|:----------------|-------------:|
| missing_developer_reply | info            |        10596 |
| missing_app_version     | info            |         2125 |

## Operating Assumption Notes

### Once-daily vs. twice-daily collection

This run provides the first same-day second-collection result. It should be compared with the Day 1-Day 3 controlled repeated baseline, especially Day 3, because Day 3 is the latest once-daily-style baseline run before cadence testing.

### High-activity vs. lower-activity apps

App-level new inserts and new insert rates show whether some apps are producing meaningfully more newly captured reviews than others under the same target and source setup.

### Duplicate rate under higher frequency

The duplicate rate from Run A indicates whether a same-day second collection starts producing too many repeated records relative to new captures.

### Runtime and database growth

Runtime, database growth in MB, and review row growth show whether the higher collection frequency is still operationally reasonable.

### App-specific instability or quality-flag patterns

App-level errors, runtime, and quality flags help identify whether any app is unstable or producing unusual data-quality behavior.

## Next Step

Run at least one more cadence test later under the same setup before making a final recommendation on once-daily vs. twice-daily collection.
