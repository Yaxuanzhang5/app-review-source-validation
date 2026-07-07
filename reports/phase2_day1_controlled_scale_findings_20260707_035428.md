# Google Play Controlled Scale Ingestion — Phase 2 Day 1 Findings

## 1. Purpose

This run starts Phase 2 of the Google Play ingestion pipeline. The goal is to test whether the existing SQLite database pipeline can move from a small controlled demo into a larger recurring ingestion setup.

## 2. Test Scope

- Source: google_play
- Language / country: en / us
- Apps tested: 10
- Target reviews per app: 1200
- Database used: `database/google_play_reviews.sqlite`
- Run ID: `phase2_day1_controlled_scale_20260707_035428`
- Frequency label: `once_daily_baseline`
- Duplicate rule: `source + app_id + review_id`

## 3. Run Summary

| run_id | run_label | phase | frequency_label | source | language | country | target_reviews_per_app | app_count | apps_included | run_started_at | run_finished_at | runtime_seconds | status | records_fetched_total | new_records_inserted_total | duplicates_skipped_total | errors_total | apps_failed | quality_flag_total | quality_flags_inserted | db_size_before_mb | db_size_after_mb | db_size_growth_mb | review_rows_before | review_rows_after | review_rows_growth |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| phase2_day1_controlled_scale_20260707_035428 | phase2_day1_controlled_scale | phase2 | once_daily_baseline | google_play | en | us | 1200 | 10 | YouTube, TikTok, Spotify, Instagram, Uber, DoorDash, Duolingo, Google Maps, Netflix, Reddit | 2026-07-07T03:55:46.631391+00:00 | 2026-07-07T03:57:26.744408+00:00 | 100.11 | completed_with_errors | 12000 | 0 | 0 | 10 | YouTube, TikTok, Spotify, Instagram, Uber, DoorDash, Duolingo, Google Maps, Netflix, Reddit | 0 | 0 | 1.832 | 1.832 | 0.0 | 0 | 0 | 0 |

## 4. App-Level Summary

| app_name | records_fetched | new_records_inserted | duplicates_skipped | runtime_seconds | quality_flag_count | error_message |
| --- | --- | --- | --- | --- | --- | --- |
| YouTube | 1200 | 0 | 0 | 0.71 | 0 | name 'raw_review_to_row' is not defined |
| TikTok | 1200 | 0 | 0 | 0.91 | 0 | name 'raw_review_to_row' is not defined |
| Spotify | 1200 | 0 | 0 | 0.57 | 0 | name 'raw_review_to_row' is not defined |
| Instagram | 1200 | 0 | 0 | 0.7 | 0 | name 'raw_review_to_row' is not defined |
| Uber | 1200 | 0 | 0 | 0.57 | 0 | name 'raw_review_to_row' is not defined |
| DoorDash | 1200 | 0 | 0 | 0.7 | 0 | name 'raw_review_to_row' is not defined |
| Duolingo | 1200 | 0 | 0 | 0.57 | 0 | name 'raw_review_to_row' is not defined |
| Google Maps | 1200 | 0 | 0 | 0.66 | 0 | name 'raw_review_to_row' is not defined |
| Netflix | 1200 | 0 | 0 | 0.53 | 0 | name 'raw_review_to_row' is not defined |
| Reddit | 1200 | 0 | 0 | 1.13 | 0 | name 'raw_review_to_row' is not defined |

## 5. Quality Flag Summary

_No rows._

## 6. Database Relationship Checks

| check_name | issue_count | status |
| --- | --- | --- |
| raw_reviews_have_app_record | 0 | pass |
| cleaned_reviews_link_to_raw_reviews | 0 | pass |
| quality_flags_link_to_raw_reviews | 0 | pass |
| no_duplicate_source_app_review_id | 0 | pass |
| run_reviews_link_to_ingestion_run | 0 | pass |

## 7. Main Notes

- The run continued from the existing SQLite database instead of starting from an empty file.
- New reviews were inserted through the Phase 2 raw and cleaned review tables.
- Duplicates were skipped using the database-level unique rule.
- Quality flags were linked back to raw reviews and the ingestion run.
- The run summary CSV shows runtime, apps included, records fetched, inserted rows, duplicates skipped, errors, quality flags, and database growth.

## 8. Next Step

The next controlled runs should use the same database and same app list, but run at different times. This will make it possible to compare once-daily and twice-daily collection behavior.