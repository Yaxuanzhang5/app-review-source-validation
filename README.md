# Google Play Review Ingestion Pipeline — Phase 2 Controlled Repeated Runs and Cadence Test

## Project Overview

This repository contains the technical validation and controlled ingestion work for recurring public app-review collection.

The project began by testing Google Play and iOS App Store public review sources. Phase 2 then focused on Google Play and moved from small technical tests to a persistent SQLite ingestion pipeline with:

- repeated review collection
- raw and cleaned review storage
- deterministic duplicate prevention
- app-level and run-level metrics
- data-quality flags
- database integrity checks
- timestamp-based freshness analysis
- once-daily versus twice-daily cadence evaluation

The latest database contains six completed Phase 2 runs for the same 10 apps under a controlled 1,200-review-per-app setup.

---

## Current Project Status

Phase 2 controlled collection and cadence testing are complete.

Final database state:

| Metric | Final value |
|---|---:|
| Apps | 10 |
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

The final validated database is available here:

[`database/google_play_reviews_after_runB_followup.sqlite.zip`](database/google_play_reviews_after_runB_followup.sqlite.zip)

---

## Controlled Collection Setup

The same configuration was maintained throughout the controlled Phase 2 cadence work.

| Setting | Value |
|---|---|
| Source | Google Play |
| Library | `google-play-scraper` |
| Collection method | `reviews()` |
| Sort order | `Sort.NEWEST` |
| Language | English (`en`) |
| Country | United States (`us`) |
| Apps | 10 fixed apps |
| Target | 1,200 reviews per app |
| Maximum expected batch | 12,000 reviews per run |
| Request delay | 2 seconds between app requests |
| Database | SQLite |
| Duplicate identity | `source + app_id + review_id` |

### Fixed App List

1. YouTube — `com.google.android.youtube`
2. TikTok — `com.zhiliaoapp.musically`
3. Spotify — `com.spotify.music`
4. Instagram — `com.instagram.android`
5. Uber — `com.ubercab`
6. DoorDash — `com.dd.doordash`
7. Duolingo — `com.duolingo`
8. Google Maps — `com.google.android.apps.maps`
9. Netflix — `com.netflix.mediaclient`
10. Reddit — `com.reddit.frontpage`

The app list, order, source settings, target size, schema, database continuation, and duplicate-prevention logic were kept unchanged during the controlled cadence tests.

---

## Database Design

The Phase 2 database contains six main tables:

| Table | Purpose |
|---|---|
| `phase2_apps` | Fixed app configuration and store metadata |
| `phase2_ingestion_runs` | Run-level status, timing, totals, and database growth |
| `phase2_app_run_summary` | App-level fetched, inserted, duplicate, quality, and runtime metrics |
| `phase2_reviews_raw` | Original normalized review records and source payloads |
| `phase2_reviews_cleaned` | Cleaned review content and analysis-ready fields |
| `phase2_quality_flags` | Run-scoped data-quality findings |

### Duplicate Prevention

Each review receives a deterministic `review_key` derived from:

```text
source | app_id | review_id
