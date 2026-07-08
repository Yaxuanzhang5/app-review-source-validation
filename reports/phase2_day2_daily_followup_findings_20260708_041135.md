# Google Play Controlled Scale Ingestion — Phase 2 Day 2 Findings

## 1. Purpose

This run continues Phase 2 of the Google Play review ingestion pipeline.

Phase 2 Day 1 created the controlled baseline database with 12,000 reviews across 10 apps. Phase 2 Day 2 repeats the same ingestion scope using the clean Day 1 database to test duplicate handling, new review capture, run stability, quality flags, and database growth.

## 2. Test Scope

- Source: google_play
- Language / country: en / us
- Apps tested: 10
- Target reviews per app: 1200
- Database used: `database/google_play_reviews.sqlite`
- Run ID: `phase2_day2_daily_followup_20260708_041135`
- Frequency label: `daily_followup`
- Duplicate rule: `source + app_id + review_id`

## 3. Day 2 Run Summary

| run_id | run_label | phase | frequency_label | source | language | country | target_reviews_per_app | app_count | apps_included | run_started_at | run_finished_at | runtime_seconds | status | records_fetched_total | new_records_inserted_total | duplicates_skipped_total | errors_total | apps_failed | quality_flag_total | quality_flags_inserted | db_size_before_mb | db_size_after_mb | db_size_growth_mb | review_rows_before | review_rows_after | review_rows_growth |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| phase2_day2_daily_followup_20260708_041135 | phase2_day2_daily_followup | phase2 | daily_followup | google_play | en | us | 1200 | 10 | YouTube, TikTok, Spotify, Instagram, Uber, DoorDash, Duolingo, Google Maps, Netflix, Reddit | 2026-07-08T04:16:09.351152+00:00 | 2026-07-08T04:17:25.150737+00:00 | 75.8 | completed | 12000 | 156 | 11844 | 0 |  | 12638 | 12638 | 25.4922 | 30.1875 | 4.6953 | 12000 | 12156 | 156 |

## 4. Day 1 vs Day 2 Comparison

| run_label | frequency_label | status | records_fetched_total | new_records_inserted_total | duplicates_skipped_total | errors_total | quality_flag_total | db_size_before_mb | db_size_after_mb | db_size_growth_mb | review_rows_before | review_rows_after | review_rows_growth | runtime_seconds |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| phase2_day1_controlled_scale | once_daily_baseline | completed | 12000 | 12000 | 0 | 0 | 12633 | 1.83203125 | 25.4921875 | 23.66015625 | 0 | 12000 | 12000 | 23.271117 |
| phase2_day2_daily_followup | daily_followup | completed | 12000 | 156 | 11844 | 0 | 12638 | 25.4921875 | 30.1875 | 4.6953125 | 12000 | 12156 | 156 | 75.799585 |

## 5. App-Level Summary

| app_name | records_fetched | new_records_inserted | duplicates_skipped | runtime_seconds | quality_flag_count | error_message |
| --- | --- | --- | --- | --- | --- | --- |
| YouTube | 1200 | 33 | 1167 | 1.02 | 1221 |  |
| TikTok | 1200 | 7 | 1193 | 0.78 | 630 |  |
| Spotify | 1200 | 15 | 1185 | 0.71 | 1247 |  |
| Instagram | 1200 | 52 | 1148 | 0.98 | 1584 |  |
| Uber | 1200 | 13 | 1187 | 0.63 | 1367 |  |
| DoorDash | 1200 | 0 | 1200 | 0.73 | 1326 |  |
| Duolingo | 1200 | 28 | 1172 | 0.76 | 1276 |  |
| Google Maps | 1200 | 3 | 1197 | 0.87 | 965 |  |
| Netflix | 1200 | 2 | 1198 | 0.8 | 1578 |  |
| Reddit | 1200 | 3 | 1197 | 0.6 | 1444 |  |

## 6. Quality Flag Summary

| run_id | flag_name | flag_severity | flag_count |
| --- | --- | --- | --- |
| phase2_day2_daily_followup_20260708_041135 | missing_app_version | info | 2067 |
| phase2_day2_daily_followup_20260708_041135 | missing_developer_reply | info | 10571 |

## 7. Database Relationship Checks

| check_name | issue_count | status |
| --- | --- | --- |
| raw_reviews_have_app_record | 0 | pass |
| cleaned_reviews_link_to_raw_reviews | 0 | pass |
| quality_flags_link_to_raw_reviews | 0 | pass |
| quality_flags_link_to_ingestion_run | 0 | pass |
| no_duplicate_source_app_review_id | 0 | pass |
| run_reviews_link_to_ingestion_run | 0 | pass |

## 8. Main Notes

- The run started from the clean Phase 2 Day 1 database.
- The same 10 apps and same target review count were used as Day 1.
- Day 2 duplicate counts are meaningful because the database already contained Day 1 records.
- The run summary captures fetched records, inserted records, duplicates skipped, errors, quality flags, database size growth, and row growth.
- Relationship checks passed after the repeated ingestion run.
- No failed Day 1 or old Day 2 runs are included in the final database history.

## 9. Next Step

The next run can use the same database and app list to test another collection time, such as a same-day evening run or a Day 3 daily follow-up run.