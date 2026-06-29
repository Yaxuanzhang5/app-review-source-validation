# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to evaluate whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, and exploratory/data quality analysis.

Google Play is tested as the primary source. The iOS App Store public RSS feed is tested as a secondary source.

---

## Latest Update: SQL Database Schema Design

Based on the Run 4 Google Play EDA, the project has moved from data quality validation into the SQL/database schema design stage.

The new schema design is documented in:

* `database_design/google_play_review_schema.md`
* `database_design/schema.sql`

The proposed schema covers:

* app/source metadata,
* ingestion runs,
* review-level records,
* raw vs. cleaned review text,
* quality flags,
* timestamps,
* app version fields,
* duplicate review handling,
* repeated generic content indicators,
* and future analysis support.

The design keeps Google Play as the primary source for the first recurring ingestion pilot. Low-signal reviews and repeated generic content are preserved with quality flags instead of being removed, so downstream filtering can remain flexible and traceable.

---

## Current Project Status

The project has completed the initial source validation and Google Play data quality EDA stage.

The current conclusion is:

* Google Play is suitable as the primary source for the first recurring ingestion pilot.
* Google Play public review collection supports repeated ingestion testing without requiring app owner access.
* Review-level metadata is strong enough for source validation, recurring collection checks, and downstream exploratory analysis.
* Duplicate and repeated-content issues should be tracked explicitly rather than removed without documentation.
* Low-signal reviews are a real data quality issue, but they do not invalidate the source if preserved with proper flags.
* iOS App Store public RSS review data remains useful as a secondary or comparison source, but it has stronger public feed limitations than Google Play.

The project is now moving into database schema design for the Google Play review pipeline.

---

## Repository Structure

```text
app-review-source-validation/
├── README.md
├── requirements.txt
├── data/
├── notebooks/
├── outputs/
├── reports/
└── database_design/
    ├── google_play_review_schema.md
    └── schema.sql
```

### Folder Descriptions

| Folder / File      | Purpose                                                        |
| ------------------ | -------------------------------------------------------------- |
| `README.md`        | Main project overview and current status                       |
| `requirements.txt` | Python package requirements used for the validation work       |
| `data/`            | Input or sample data files used during validation              |
| `notebooks/`       | Colab/Jupyter notebooks for source testing and EDA             |
| `outputs/`         | Exported CSVs, summaries, and validation outputs               |
| `reports/`         | Written summaries or analysis notes from validation runs       |
| `database_design/` | SQL/database schema design for the Google Play review pipeline |

---

## Source Validation Scope

This project focuses on two public app review sources:

### 1. Google Play Reviews

Google Play is the primary tested source.

The validation work checks:

* whether reviews can be collected through public/community tools,
* review volume availability,
* review-level metadata fields,
* timestamp availability,
* app version field coverage,
* duplicate review handling,
* repeated ingestion feasibility,
* low-signal review content,
* repeated generic content,
* and data quality issues relevant to downstream analysis.

### 2. iOS App Store Reviews

The iOS App Store public RSS feed is tested as a secondary source.

The validation work checks:

* public RSS feed accessibility,
* review count limitations,
* page/country coverage,
* metadata fields,
* duplicate behavior across country/page combinations,
* empty response frequency,
* and whether it can support repeated collection at a smaller scale.

---

## Validation Runs

### Run 1: Initial Source Feasibility Check

The first validation run focused on whether public review sources could be accessed and whether the available fields were useful for a recurring review ingestion pipeline.

Key questions:

* Can public review data be collected without owner/admin access?
* What fields are available?
* Are timestamps available?
* Are review IDs available for deduplication?
* Is the source realistic for recurring ingestion?

Main outcome:

* Google Play appeared feasible for recurring public review ingestion.
* iOS App Store public RSS was usable but more limited.
* Google Play was selected for deeper validation.

---

### Run 2: Repeated Collection and Stability Check

The second validation run focused on repeated collection behavior.

Key questions:

* Can the same apps be collected repeatedly?
* Are review IDs stable across runs?
* Can new vs. already-known reviews be identified?
* Are duplicate records manageable?
* Does the source remain stable enough for a recurring pipeline?

Main outcome:

* Google Play review IDs were suitable for deduplication.
* Repeated collection was feasible.
* The pipeline should preserve run-level metadata to track newly inserted versus already-known records.
* This finding directly supports the later database schema design.

---

### Run 3: Cross-Run Comparison and Freshness Tracking

The third validation run focused on comparing results across multiple runs.

Key questions:

* How many reviews are newly collected versus repeated across runs?
* Does the source provide enough timestamp information for freshness tracking?
* Are metadata fields stable across repeated runs?
* What source limitations should be documented?

Main outcome:

* Google Play continued to support repeated collection and cross-run comparison.
* Review-level timestamps supported freshness analysis.
* Some metadata fields, especially app version-related fields, were incomplete and should be treated as nullable fields.
* The recurring pipeline should store both first-seen and last-seen timestamps.

---

### Run 4: Google Play 10K+ Review EDA

The fourth validation run expanded the Google Play test into a deeper EDA with a larger review sample.

Key questions:

* What does the Google Play review data look like at larger scale?
* What data quality issues appear in a 10K+ review sample?
* How common are low-signal reviews?
* How should repeated generic content be handled?
* Are app version fields complete enough for downstream analysis?
* Does the data quality support moving forward with Google Play as the primary source?

Main outcome:

* The larger Google Play EDA supported using Google Play as the primary source for the first recurring ingestion pilot.
* Low-signal reviews and repeated generic content are important quality issues, but they should be flagged rather than removed.
* App version fields are useful when available but should remain nullable.
* The next step is SQL/database schema design for a traceable recurring ingestion pipeline.

---

## Key Data Quality Findings

### 1. Google Play Review IDs Support Deduplication

Google Play review-level IDs can be used to identify duplicate or already-known reviews across repeated runs.

For the database design, the main deduplication key is:

```text
(app_source_id, source_review_id)
```

This prevents the same review from being inserted repeatedly while still allowing the pipeline to track when that review was observed again.

---

### 2. Low-Signal Reviews Should Be Preserved with Flags

Some reviews contain very limited analytical signal, such as extremely short or generic text.

Examples of low-signal patterns may include:

* very short reviews,
* empty or near-empty text after cleaning,
* generic positive comments,
* generic repeated phrases.

These reviews should not be deleted automatically. Instead, the pipeline should preserve them with quality flags so downstream users can decide whether to include or exclude them.

---

### 3. Repeated Generic Content Is Not the Same as Duplicate Reviews

Multiple users may leave the same short review text, such as “Good app” or “Nice”.

These should not be treated as duplicate review records unless they share the same source review ID.

The schema therefore separates:

* source-level duplicate review IDs,
* and repeated generic review content.

Repeated content should be tracked using normalized text and content hash fields.

---

### 4. App Version Fields Are Useful but Incomplete

Google Play review data may include app version-related fields, but coverage may be incomplete.

The schema stores these fields as nullable:

```text
review_created_version
app_version
```

Missing version values are tracked using quality flags:

```text
is_missing_review_created_version
is_missing_app_version
```

This keeps valid reviews in the dataset while still preserving metadata completeness information.

---

### 5. Run-Level Metadata Is Required for Recurring Ingestion

A recurring pipeline needs to know:

* when each ingestion run started and ended,
* which apps were collected,
* how many rows were fetched,
* how many reviews were newly inserted,
* how many were already known,
* whether any app-level collection failed,
* and what raw payload was observed during each run.

This is why the schema separates:

* `ingestion_runs`,
* `ingestion_run_targets`,
* `reviews`,
* and `review_observations`.

---

## SQL Database Schema Design

The proposed Google Play review pipeline schema uses six core tables:

| Table                   | Purpose                                              |
| ----------------------- | ---------------------------------------------------- |
| `app_sources`           | Stores app/source metadata                           |
| `ingestion_runs`        | Stores one row per ingestion job                     |
| `ingestion_run_targets` | Stores one row per app/source collected within a run |
| `reviews`               | Stores canonical review-level records                |
| `review_observations`   | Stores run-level review observation history          |
| `review_quality_flags`  | Stores review-level data quality flags               |

The full schema explanation is available here:

```text
database_design/google_play_review_schema.md
```

The SQL DDL file is available here:

```text
database_design/schema.sql
```

---

## Database Design Goals

The schema is designed to be:

### Clean

The schema separates source metadata, ingestion runs, review records, run observations, and quality flags into different tables.

This avoids a single flat table becoming difficult to maintain as the pipeline grows.

### Traceable

Each review can be traced back to:

* the app/source,
* the ingestion run,
* the run target,
* the first time it was seen,
* the last time it was observed,
* and the original source payload.

### Extensible

The schema can support future changes, including:

* more apps,
* more countries/languages,
* new quality flags,
* new source fields,
* additional downstream analysis needs,
* and potential future public review sources.

---

## Deduplication Logic

The main source-level deduplication key is:

```text
(app_source_id, source_review_id)
```

The ingestion logic should work as follows:

1. Fetch reviews for each app/source.
2. Map each review to an internal `app_source_id`.
3. Use the source review ID as `source_review_id`.
4. Check whether `(app_source_id, source_review_id)` already exists in the `reviews` table.
5. If it does not exist, insert the review as a new canonical review.
6. If it already exists, do not insert a duplicate review row.
7. Update mutable fields if needed, such as helpful count, developer reply, app version fields, and last-seen timestamp.
8. Store one row in `review_observations` to track whether the review was inserted, already known, or updated during that run.

This design supports recurring ingestion without losing run-level collection history.

---

## Quality Flag Design

The pipeline should preserve review quality issues with explicit flags.

Example flags include:

| Flag                                | Purpose                                            |
| ----------------------------------- | -------------------------------------------------- |
| `is_empty_after_cleaning`           | Indicates review text becomes empty after cleaning |
| `is_short_text`                     | Indicates very short review text                   |
| `is_low_signal`                     | Indicates limited analytical signal                |
| `is_repeated_generic_content`       | Indicates repeated normalized text                 |
| `is_missing_review_created_version` | Indicates missing review-created app version       |
| `is_missing_app_version`            | Indicates missing app version field                |
| `has_developer_reply`               | Indicates whether the review has a developer reply |

The quality flag logic should be versioned using:

```text
quality_flag_version
```

This allows future changes to the flagging rules without losing traceability.

---

## Analysis Support

The schema supports downstream analysis such as:

* rating distribution by app,
* review volume by source review date,
* review volume by ingestion date,
* new versus already-known review counts,
* low-signal review rate,
* repeated generic content rate,
* app version coverage,
* review length distribution,
* developer reply coverage,
* and review trends over time.

The SQL design also includes an analysis-ready view:

```text
vw_google_play_reviews_analysis
```

This view combines app metadata, review-level fields, and quality flags for easier downstream use.

---

## How to Use This Repository

### 1. Review the Source Validation Work

Start with the notebooks, outputs, and reports folders to understand the source validation and EDA work:

```text
notebooks/
outputs/
reports/
```

### 2. Review the Database Design

The current database design work is located in:

```text
database_design/
```

Main files:

```text
database_design/google_play_review_schema.md
database_design/schema.sql
```

### 3. Install Python Requirements

If running the notebooks locally, install the required packages:

```bash
pip install -r requirements.txt
```

### 4. Run the Notebooks

The validation notebooks are stored in:

```text
notebooks/
```

They are intended to document the public source testing, repeated collection checks, and Google Play review EDA process.

---

## Current Conclusion

The validation work supports moving forward with Google Play as the primary source for the first recurring review ingestion pilot.

The most important next step is to convert the validation findings into a traceable SQL-backed ingestion structure.

The current schema design addresses this by documenting:

* app/source metadata,
* ingestion run tracking,
* review-level canonical records,
* run-level review observations,
* raw and cleaned text fields,
* quality flags,
* app version fields,
* duplicate handling,
* repeated-content indicators,
* timestamps,
* and analysis-ready outputs.

Overall, Google Play remains the strongest source for the first recurring ingestion pilot, while iOS App Store public RSS can remain a secondary or comparison source.
