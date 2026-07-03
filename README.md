# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to evaluate whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, database storage, and downstream data quality analysis.

Google Play is tested as the primary source. The iOS App Store public RSS feed is tested as a secondary source.

---

## Latest Update: Run 5 Google Play Ingestion and Database Pipeline

The project has now moved from source validation and schema design into an actual database-backed ingestion workflow.

Run 5 connects the Google Play review schema to a working SQLite ingestion pipeline. The notebook collects Google Play reviews, processes the records, inserts them into a database, handles duplicate reviews, records ingestion run information, preserves quality flags, and keeps raw and cleaned review text linked.

Main Run 5 files:

```text
notebooks/Google_Play_Ingestion_Database_Pipeline.ipynb
notebooks/Google_Play_Ingestion_Database_Pipeline_Day2.ipynb
database/google_play_reviews.sqlite
outputs/run5_ingestion_database_pipeline/
```

The first controlled implementation used a small batch:

```text
Apps: YouTube, TikTok, Spotify
Country: US
Language: English
Sort order: Newest
Requested count: 100 reviews per app
```

The first controlled run collected 300 reviews and inserted all 300 as new database rows.

The immediate second controlled run used the same targets and collection settings to test duplicate handling. It collected 300 reviews again, inserted 0 new rows, and correctly identified all 300 records as existing duplicate records.

Database validation checks passed:

```text
total_app_sources: 3
total_ingestion_runs: 2
total_reviews: 300
total_review_texts: 300
total_quality_flags: 600
duplicate_review_rows_same_app_source: 0
reviews_without_text_link: 0
quality_flags_without_review: 0
```

This confirmed that the basic end-to-end ingestion and database workflow was working.

---

## Day 2 Repeated Collection Update

A Day 2 repeated collection test was completed using the existing SQLite database from the previous controlled test.

This Day 2 run was not started from an empty database. Before the Day 2 run, the uploaded database already contained:

```text
app_sources: 3
ingestion_runs: 2
ingestion_run_targets: 6
reviews: 300
review_texts: 300
review_quality_flags: 600
```

The Day 2 run used the same app targets and collection settings:

```text
Apps: YouTube, TikTok, Spotify
Country: US
Language: English
Sort order: Newest
Requested count: 100 reviews per app
```

The Day 2 run fetched 300 reviews across the three apps. Compared with the existing database, all 300 collected records were previously unseen source review IDs. The pipeline inserted 300 new review rows and identified 0 existing duplicates in this run.

After the Day 2 run, the database contained:

```text
app_sources: 3
ingestion_runs: 3
ingestion_run_targets: 9
reviews: 600
review_texts: 600
review_quality_flags: 900
duplicate_review_rows_same_app_source: 0
reviews_without_text_link: 0
quality_flags_without_review: 0
```

This confirms that the pipeline remained stable during the Day 2 repeated collection test. It also shows that the database-backed workflow can capture previously unseen review records over time while preserving ingestion run information, quality flags, and raw/cleaned text linkage.

---

## Current Project Status

The project has completed:

- initial public source feasibility testing
- repeated Google Play collection checks
- cross-run comparison and freshness tracking
- Google Play 10K+ review EDA
- SQL/database schema design
- first working Google Play ingestion and SQLite database implementation
- Day 2 repeated collection test using the existing database

Current conclusion:

- Google Play is suitable as the primary source for the first recurring ingestion pilot.
- Google Play public review collection supports repeated ingestion testing without requiring app owner access.
- Review-level IDs support deduplication across repeated runs.
- Review-level metadata is strong enough for source validation, database ingestion, recurring collection checks, and downstream exploratory analysis.
- Low-signal reviews and repeated generic content should be preserved with quality flags rather than removed without documentation.
- The SQLite implementation successfully inserts new reviews, handles duplicates, stores ingestion run information, preserves quality flags, and keeps raw and cleaned text linked.
- The Day 2 repeated collection test shows that the pipeline can continue from an existing database and capture previously unseen review records over time.
- iOS App Store public RSS review data remains useful as a secondary or comparison source, but it has stronger public feed limitations than Google Play.

The project is now moving from a basic working pipeline into additional repeated collection testing over time.

---

## Repository Structure

```text
app-review-source-validation/
├── README.md
├── requirements.txt
├── data/
├── database/
│   └── google_play_reviews.sqlite
├── database_design/
│   ├── google_play_review_schema.md
│   └── schema.sql
├── notebooks/
│   ├── Google_Play_Ingestion_Database_Pipeline.ipynb
│   └── Google_Play_Ingestion_Database_Pipeline_Day2.ipynb
├── outputs/
│   └── run5_ingestion_database_pipeline/
└── reports/
```

### Folder Descriptions

| Folder / File | Purpose |
| --- | --- |
| `README.md` | Main project overview and current status |
| `requirements.txt` | Python package requirements used for validation and ingestion work |
| `data/` | Input or sample data files used during earlier validation work |
| `database/` | SQLite database generated and updated by the ingestion pipeline |
| `database_design/` | SQL/database schema design documents |
| `notebooks/` | Colab/Jupyter notebooks for validation, EDA, and ingestion implementation |
| `outputs/` | Exported CSVs, summaries, schema copies, and validation outputs |
| `reports/` | Written summaries and analysis notes from validation runs |

---

## Source Validation Scope

This project focuses on two public app review sources.

### 1. Google Play Reviews

Google Play is the primary tested source.

The validation work checks:

- whether reviews can be collected through public/community tools
- review volume availability
- review-level metadata fields
- timestamp availability
- app version field coverage
- duplicate review handling
- repeated ingestion feasibility
- low-signal review content
- repeated generic content
- database insertion
- data quality issues relevant to downstream analysis

### 2. iOS App Store Reviews

The iOS App Store public RSS feed is tested as a secondary source.

The validation work checks:

- public RSS feed accessibility
- review count limitations
- page/country coverage
- metadata fields
- duplicate behavior across country/page combinations
- empty response frequency
- whether it can support repeated collection at a smaller scale

---

## Validation Runs

### Run 1: Initial Source Feasibility Check

The first validation run focused on whether public review sources could be accessed and whether the available fields were useful for a recurring review ingestion pipeline.

Key questions:

- Can public review data be collected without owner/admin access?
- What fields are available?
- Are timestamps available?
- Are review IDs available for deduplication?
- Is the source realistic for recurring ingestion?

Main outcome:

- Google Play appeared feasible for recurring public review ingestion.
- iOS App Store public RSS was usable but more limited.
- Google Play was selected for deeper validation.

---

### Run 2: Repeated Collection and Stability Check

The second validation run focused on repeated collection behavior.

Key questions:

- Can the same apps be collected repeatedly?
- Are review IDs stable across runs?
- Can new versus already-known reviews be identified?
- Are duplicate records manageable?
- Does the source remain stable enough for a recurring pipeline?

Main outcome:

- Google Play review IDs were suitable for deduplication.
- Repeated collection was feasible.
- The pipeline should preserve run-level metadata to track newly inserted versus already-known records.
- This finding directly supported the later database schema design.

---

### Run 3: Cross-Run Comparison and Freshness Tracking

The third validation run focused on comparing results across multiple runs.

Key questions:

- How many reviews are newly collected versus repeated across runs?
- Does the source provide enough timestamp information for freshness tracking?
- Are metadata fields stable across repeated runs?
- What source limitations should be documented?

Main outcome:

- Google Play continued to support repeated collection and cross-run comparison.
- Review-level timestamps supported freshness analysis.
- Some metadata fields, especially app version-related fields, were incomplete and should be treated as nullable fields.
- The recurring pipeline should store both first-seen and last-seen information.

---

### Run 4: Google Play 10K+ Review EDA

The fourth validation run expanded the Google Play test into a deeper EDA with a larger review sample.

Key questions:

- What does the Google Play review data look like at larger scale?
- What data quality issues appear in a 10K+ review sample?
- How common are low-signal reviews?
- How should repeated generic content be handled?
- Are app version fields complete enough for downstream analysis?
- Does the data quality support moving forward with Google Play as the primary source?

Main outcome:

- The larger Google Play EDA supported using Google Play as the primary source for the first recurring ingestion pilot.
- Low-signal reviews and repeated generic content are important quality issues, but they should be flagged rather than removed.
- App version fields are useful when available but should remain nullable.
- The project moved into SQL/database schema design for a traceable recurring ingestion pipeline.

---

### Run 5: Google Play Ingestion and Database Pipeline

The fifth run connects the schema design to an actual ingestion workflow.

Key questions:

- Can the pipeline collect Google Play reviews and insert them into a database?
- Can new reviews be inserted correctly?
- Can duplicate reviews be identified during repeated runs?
- Can ingestion run information be recorded?
- Can quality flags be preserved?
- Can raw and cleaned review text stay linked?
- Can the database structure support future repeated ingestion?
- Can the same pipeline continue from an existing database on a later collection day?

Main outcome:

- The first controlled run collected 300 reviews across three apps and inserted all 300 as new database rows.
- The immediate duplicate handling run collected 300 reviews again and correctly identified all 300 as already existing records.
- The Day 2 repeated collection run continued from the existing database and inserted 300 previously unseen review records.
- No duplicate review rows were created.
- All reviews had linked raw and cleaned text records.
- All quality flag rows were linked back to review records.
- The basic end-to-end ingestion and database workflow is working.
- The Day 2 run provides initial evidence that the pipeline can capture new records over time.

---

## Run 5 Output Files

Run 5 output files are stored in:

```text
outputs/run5_ingestion_database_pipeline/
```

Main files:

| File | Purpose |
| --- | --- |
| `schema_used_for_run5.sql` | SQL schema copy used by the notebook |
| `ingestion_run_summary.csv` | Run-level metadata for ingestion runs |
| `ingestion_target_summary.csv` | App-level ingestion result for each run |
| `database_validation_summary.csv` | Database validation checks |
| `quality_flag_summary.csv` | Summary of quality flags created during ingestion |
| `sample_inserted_reviews.csv` | Sample review records with raw and cleaned text |
| `duplicate_handling_check.csv` | Duplicate handling results from the controlled runs |
| `table_counts.csv` | Final row counts for each database table |
| `review_level_database_export.csv` | Review-level export from the SQLite database |
| `day2_run_comparison.csv` | App-level comparison across all runs including Day 2 |
| `aggregated_run_summary.csv` | Run-level aggregated summary across all runs |
| `day2_database_validation_summary.csv` | Day 2 database validation results |
| `day2_quality_flag_summary.csv` | Day 2 quality flag summary |
| `day2_sample_inserted_reviews.csv` | Sample review rows after Day 2 |
| `day2_table_counts.csv` | Table row counts after Day 2 |
| `day2_review_level_database_export.csv` | Review-level database export after Day 2 |

The SQLite database is stored in:

```text
database/google_play_reviews.sqlite
```

---

## Run 5 Controlled Test Result

Run 5 used three high-volume apps:

| App | Google Play App ID |
| --- | --- |
| YouTube | `com.google.android.youtube` |
| TikTok | `com.zhiliaoapp.musically` |
| Spotify | `com.spotify.music` |

Collection settings:

| Setting | Value |
| --- | --- |
| Country | `us` |
| Language | `en` |
| Sort order | `newest` |
| Requested reviews per app | `100` |

Initial controlled run:

| Metric | Result |
| --- | --- |
| Apps collected | 3 |
| Reviews fetched | 300 |
| New rows inserted | 300 |
| Existing duplicates found | 0 |
| Failed app collections | 0 |

Immediate duplicate handling run:

| Metric | Result |
| --- | --- |
| Apps collected | 3 |
| Reviews fetched | 300 |
| New rows inserted | 0 |
| Existing duplicates found | 300 |
| Failed app collections | 0 |

Day 2 repeated collection run:

| Metric | Result |
| --- | --- |
| Apps collected | 3 |
| Reviews fetched | 300 |
| New rows inserted | 300 |
| Existing duplicates found | 0 |
| Failed app collections | 0 |

This confirms that the pipeline can insert new records, avoid duplicate rows during an immediate repeated run, and continue from the existing database during a later repeated collection test.

---

## Day 2 Database Validation Results

After the Day 2 run, the database validation checks showed:

| Check | Result |
| --- | --- |
| Total app sources | 3 |
| Total ingestion runs | 3 |
| Total ingestion run targets | 9 |
| Total reviews | 600 |
| Total review text rows | 600 |
| Total quality flag rows | 900 |
| Duplicate review rows for same app source and source review ID | 0 |
| Reviews without linked text records | 0 |
| Quality flags without linked review records | 0 |

These checks confirm that:

- new reviews were inserted correctly
- repeated reviews were not inserted as duplicate rows
- raw and cleaned text records remained linked to review records
- quality flags remained linked to review records
- run-level and app-level metadata were preserved
- the Day 2 repeated collection run did not break the database structure

---

## Key Data Quality Findings

### 1. Google Play Review IDs Support Deduplication

Google Play review-level IDs can be used to identify duplicate or already-known reviews across repeated runs.

For the database design and Run 5 implementation, the main deduplication logic is based on:

```text
app source + source review id
```

This prevents the same review from being inserted repeatedly while still allowing the pipeline to track when that review was observed again.

---

### 2. Low-Signal Reviews Should Be Preserved with Flags

Some reviews contain limited analytical signal, such as extremely short or generic text.

Examples of low-signal patterns may include:

- very short reviews
- empty or near-empty text after cleaning
- generic positive comments
- generic repeated phrases

These reviews should not be deleted automatically. Instead, the pipeline should preserve them with quality flags so downstream users can decide whether to include or exclude them.

---

### 3. Repeated Generic Content Is Not the Same as Duplicate Reviews

Multiple users may leave the same short review text, such as “Good app” or “Nice”.

These should not be treated as duplicate review records unless they share the same source review ID.

The pipeline therefore separates:

- duplicate review IDs
- repeated review content

Repeated content is tracked using cleaned text and text hash fields.

---

### 4. App Version Fields Are Useful but Incomplete

Google Play review data may include app version-related fields, but coverage can be incomplete.

The database keeps app version fields nullable instead of dropping reviews with missing version values.

This keeps valid reviews in the dataset while still preserving metadata completeness information.

---

### 5. Run-Level Metadata Is Required for Recurring Ingestion

A recurring pipeline needs to know:

- when each ingestion run started and ended
- which apps were collected
- how many rows were requested
- how many rows were fetched
- how many reviews were newly inserted
- how many reviews were already known
- whether any app-level collection failed
- which run first or last observed each review

This is why the database separates:

- `app_sources`
- `ingestion_runs`
- `ingestion_run_targets`
- `reviews`
- `review_texts`
- `review_quality_flags`

---

## SQL Database Schema Design

The schema design is documented in:

```text
database_design/google_play_review_schema.md
database_design/schema.sql
```

The Run 5 SQLite implementation uses the following core tables:

| Table | Purpose |
| --- | --- |
| `app_sources` | Stores app/source metadata |
| `ingestion_runs` | Stores one row per ingestion job |
| `ingestion_run_targets` | Stores one row per app collected within each run |
| `reviews` | Stores canonical review-level metadata |
| `review_texts` | Stores raw and cleaned review text |
| `review_quality_flags` | Stores review-level data quality flags |

The design supports:

- source metadata tracking
- ingestion run tracking
- app-level run summaries
- canonical review records
- raw and cleaned text storage
- quality flag preservation
- duplicate review handling
- downstream analysis

---

## Deduplication Logic

The current ingestion logic works as follows:

1. Fetch reviews for each app/source.
2. Map each app to an internal `app_source_id`.
3. Use the source review ID as the source-level review identifier.
4. Create an internal review key from the app source and source review ID.
5. Check whether the review already exists in the `reviews` table.
6. If it does not exist, insert it as a new review.
7. If it already exists, do not insert a duplicate review row.
8. Update the existing row with the latest `last_seen_run_id`.
9. Store raw and cleaned review text in `review_texts`.
10. Store quality flags in `review_quality_flags`.
11. Record run-level and app-level ingestion summary information.

This supports repeated ingestion while keeping the database traceable.

---

## Quality Flag Design

The Run 5 pipeline preserves review quality issues with explicit flags.

Current flags include:

| Flag | Purpose |
| --- | --- |
| `is_missing_review_id` | Indicates missing source review ID |
| `is_missing_text` | Indicates missing or empty review text |
| `is_short_text` | Indicates very short review text |
| `is_missing_rating` | Indicates missing rating value |
| `is_missing_review_date` | Indicates missing review timestamp |
| `is_repeated_content_in_batch` | Indicates repeated cleaned text within the same collected batch |

These flags are stored instead of deleting records, so later analysis can decide how strict the filtering should be.

---

## Database Validation Checks

Run 5 includes database validation checks to confirm that the schema and ingestion logic work correctly.

Important validation results after Day 2:

| Check | Result |
| --- | --- |
| Total app sources | 3 |
| Total ingestion runs | 3 |
| Total ingestion run targets | 9 |
| Total reviews | 600 |
| Total review text rows | 600 |
| Total quality flag rows | 900 |
| Duplicate review rows for same app source and source review ID | 0 |
| Reviews without linked text records | 0 |
| Quality flags without linked review records | 0 |

These checks confirm that:

- new reviews are inserted correctly
- repeated reviews are not inserted as duplicate rows
- raw and cleaned text records are linked to review records
- quality flags are linked to review records
- run-level and app-level metadata are preserved

---

## Analysis Support

The database and outputs support downstream analysis such as:

- rating distribution by app
- review volume by source review date
- review volume by ingestion run
- new versus already-known review counts
- duplicate handling checks
- low-signal review rate
- repeated content rate
- app version coverage
- review length distribution
- review trends over time

---

## How to Use This Repository

### 1. Review the Source Validation Work

Start with the notebooks, outputs, and reports folders to understand the earlier source validation and EDA work:

```text
notebooks/
outputs/
reports/
```

### 2. Review the Database Design

The database design work is located in:

```text
database_design/
```

Main files:

```text
database_design/google_play_review_schema.md
database_design/schema.sql
```

### 3. Review the Run 5 Ingestion Pipeline

The initial working ingestion notebook is located in:

```text
notebooks/Google_Play_Ingestion_Database_Pipeline.ipynb
```

The Day 2 repeated collection notebook is located in:

```text
notebooks/Google_Play_Ingestion_Database_Pipeline_Day2.ipynb
```

The generated SQLite database is located in:

```text
database/google_play_reviews.sqlite
```

The Run 5 validation outputs are located in:

```text
outputs/run5_ingestion_database_pipeline/
```

### 4. Install Python Requirements

If running the notebooks locally, install the required packages:

```bash
pip install -r requirements.txt
```

The main packages used include:

```text
google-play-scraper
pandas
```

SQLite is used through Python’s built-in `sqlite3` module.

### 5. Run the Notebook

The Run 5 notebooks document the first working Google Play ingestion and database implementation.

They can be used to:

- collect reviews
- insert new records
- test duplicate handling
- create quality flags
- record ingestion run metadata
- generate validation outputs
- continue repeated collection from an existing SQLite database

For repeated collection testing, the existing `google_play_reviews.sqlite` database should be reused instead of starting from an empty database.

---

## Next Steps

The immediate duplicate handling run confirms that the pipeline can avoid duplicate review rows when the same records are collected again.

The Day 2 repeated collection run confirms that the pipeline can continue from an existing database and capture previously unseen review records after time has passed.

The next repeated tests should check:

- whether the pipeline remains stable across several collection runs
- whether new reviews can continue to be captured over time
- whether already-known reviews continue to be identified as existing records
- whether run-level metadata remains consistent
- whether quality flags remain stable across repeated runs
- whether app-level collection failures or empty responses occur

Expected repeated-run output pattern:

```text
If no new review IDs are captured:
inserted_new_count = 0
duplicate_existing_count = fetched_count

If previously unseen review IDs are captured:
inserted_new_count > 0
duplicate_existing_count < fetched_count
```

This will help confirm whether the database-backed ingestion workflow can support recurring collection beyond the initial controlled tests.

---

## Current Conclusion

The validation work supports moving forward with Google Play as the primary source for the first recurring review ingestion pilot.

The project has now moved beyond source validation and schema design. Run 5 shows that a basic database-backed ingestion workflow is working.

The current implementation can:

- collect Google Play reviews
- process review records
- insert new reviews into SQLite
- avoid duplicate review rows during repeated runs
- record ingestion run information
- store app-level ingestion summaries
- preserve raw and cleaned review text
- keep text records linked to review records
- create quality flags
- export validation outputs
- continue repeated collection from an existing database

The first controlled run inserted 300 new review records. The immediate duplicate handling run fetched 300 reviews again, inserted 0 new rows, and identified all 300 as existing records. The Day 2 repeated collection run fetched another 300 reviews and inserted 300 previously unseen review records.

After the Day 2 run, the database contained 600 unique review records, 600 linked review text records, and 900 quality flag rows across 3 ingestion runs. The database validation checks still showed 0 duplicate review rows, 0 reviews without linked text records, and 0 quality flags without linked review records.

Overall, Google Play remains the strongest source for the first recurring ingestion pilot, while iOS App Store public RSS can remain a secondary or comparison source.

The next step is to continue running the same pipeline at additional collection times to further evaluate run-to-run stability and recurring new review capture.
