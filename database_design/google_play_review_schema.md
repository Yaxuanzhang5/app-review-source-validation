# Google Play Review Pipeline — SQL Database Schema Design

## 1. Purpose

This document proposes a SQL-based database schema for the Google Play review ingestion pipeline.

The goal is to create a structure that is clean, traceable, and extensible. Each review should be traceable back to:

* the app/source it came from,
* the ingestion run that collected it,
* whether it was newly inserted or already known,
* the raw and cleaned review text,
* the relevant data quality flags,
* app version fields when available,
* and duplicate or repeated-content indicators for downstream filtering and analysis.

This design is based on the Google Play review validation work from Run 1 through Run 4. The EDA showed that Google Play is strong enough to use as the primary source for the first recurring ingestion pilot. The main quality issues to preserve are low-signal reviews, repeated generic content, and incomplete app version fields. These issues should be tracked with flags instead of removed from the dataset.

---

## 2. High-Level Design

The proposed schema uses six core tables:

1. `app_sources`
   Stores app/source metadata, including platform, Google Play package name, country, language, and source URL.

2. `ingestion_runs`
   Stores one row per ingestion job or recurring collection run.

3. `ingestion_run_targets`
   Stores one row per app/source collected within a run. This allows one ingestion run to include multiple apps.

4. `reviews`
   Stores canonical review-level records. Each Google Play review should appear once per app/source based on the source review ID.

5. `review_observations`
   Stores whether a review appeared in a specific ingestion run and whether it was newly inserted or already known.

6. `review_quality_flags`
   Stores review-level quality flags for downstream filtering and analysis.

---

## 3. Table Relationship Overview

```text
app_sources
   ├──< ingestion_run_targets >── ingestion_runs
   └──< reviews
           ├──< review_observations >── ingestion_run_targets
           └── review_quality_flags
```

Relationship summary:

* One `app_sources` record can have many `reviews`.
* One `ingestion_runs` record can include many `ingestion_run_targets`.
* One `ingestion_run_targets` record represents one app/source collected during one run.
* One `reviews` record can appear in many `review_observations` across recurring runs.
* One `reviews` record has one corresponding `review_quality_flags` record.

This separation keeps the review table clean while still preserving run-level collection history.

---

## 4. Table Details

### 4.1 `app_sources`

Purpose:

Stores app-level and source-level metadata.

Example fields:

| Field            | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `app_source_id`  | Internal primary key                                    |
| `platform`       | Source platform, currently `google_play`                |
| `source_app_id`  | Google Play package name                                |
| `app_name`       | App display name                                        |
| `developer_name` | Developer or publisher name                             |
| `country_code`   | Collection country, such as `us`                        |
| `language_code`  | Collection language, such as `en`                       |
| `source_url`     | Google Play app URL                                     |
| `is_active`      | Whether this app/source is still active in the pipeline |
| `created_at`     | Row creation timestamp                                  |
| `updated_at`     | Row update timestamp                                    |

Primary key:

```text
app_source_id
```

Unique key:

```text
(platform, source_app_id, country_code, language_code)
```

Reason:

The same app may be collected under different country/language settings in the future, so the package name alone is not enough for long-term extensibility.

---

### 4.2 `ingestion_runs`

Purpose:

Stores one row per ingestion job. This table tracks the overall run status and total run-level metrics.

Example fields:

| Field                       | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `run_id`                    | Primary key for the ingestion run                   |
| `run_label`                 | Human-readable run name                             |
| `pipeline_name`             | Name of the pipeline                                |
| `source_tool`               | Tool used for collection                            |
| `source_tool_version`       | Tool/package version if available                   |
| `code_version`              | Git commit hash or code version if available        |
| `started_at`                | Run start timestamp                                 |
| `finished_at`               | Run finish timestamp                                |
| `status`                    | Run status                                          |
| `total_fetched_count`       | Total rows fetched in the run                       |
| `total_inserted_count`      | Total newly inserted reviews                        |
| `total_already_known_count` | Total reviews already seen before                   |
| `total_updated_count`       | Total existing reviews updated                      |
| `error_message`             | Error message if the run failed or partially failed |
| `run_notes`                 | Optional notes                                      |

Primary key:

```text
run_id
```

Status values:

```text
started
success
partial_success
failed
```

Reason:

This table makes recurring ingestion traceable over time. It helps answer when the pipeline ran, whether it succeeded, and how many reviews were new versus already known.

---

### 4.3 `ingestion_run_targets`

Purpose:

Stores one row per app/source collected within a run.

Example:

If one run collects 10 apps, then `ingestion_runs` has 1 row and `ingestion_run_targets` has 10 rows.

Example fields:

| Field                        | Description                                    |
| ---------------------------- | ---------------------------------------------- |
| `run_target_id`              | Primary key                                    |
| `run_id`                     | Foreign key to `ingestion_runs`                |
| `app_source_id`              | Foreign key to `app_sources`                   |
| `sort_method`                | Collection sort method, such as newest         |
| `target_count`               | Intended number of reviews to collect          |
| `page_size`                  | Number of reviews requested per batch/page     |
| `filter_score_with`          | Optional score filter                          |
| `continuation_token_start`   | Starting token if used                         |
| `continuation_token_end`     | Ending token if used                           |
| `started_at`                 | App-level collection start time                |
| `finished_at`                | App-level collection finish time               |
| `status`                     | App-level collection status                    |
| `fetched_count`              | Reviews fetched for this app/source            |
| `inserted_count`             | New reviews inserted                           |
| `already_known_count`        | Reviews already known from previous runs       |
| `updated_count`              | Existing reviews updated                       |
| `duplicate_in_run_count`     | Duplicate review IDs found inside the same run |
| `earliest_review_created_at` | Earliest source review timestamp fetched       |
| `latest_review_created_at`   | Latest source review timestamp fetched         |
| `error_message`              | App-level error message if any                 |

Primary key:

```text
run_target_id
```

Unique key:

```text
(run_id, app_source_id)
```

Reason:

This table makes it possible to track each app separately within the same run. This is useful because one app may fail while other apps succeed.

---

### 4.4 `reviews`

Purpose:

Stores the canonical review-level records. Each unique source review should appear only once per app/source.

Example fields:

| Field                    | Description                                           |
| ------------------------ | ----------------------------------------------------- |
| `review_pk`              | Internal primary key                                  |
| `app_source_id`          | Foreign key to `app_sources`                          |
| `source_review_id`       | Google Play source review ID                          |
| `source_user_name`       | User name from source if available                    |
| `score`                  | Star rating                                           |
| `thumbs_up_count`        | Helpful/upvote count                                  |
| `raw_content`            | Original review text                                  |
| `cleaned_content`        | Cleaned review text                                   |
| `content_hash`           | Hash of normalized cleaned text                       |
| `review_created_at`      | Original review timestamp from Google Play            |
| `review_created_version` | App version when the review was created, if available |
| `app_version`            | App version field if available                        |
| `reply_content`          | Developer reply text if available                     |
| `replied_at`             | Developer reply timestamp if available                |
| `first_seen_run_id`      | First ingestion run that inserted this review         |
| `first_seen_at`          | Time this review first entered the database           |
| `last_seen_run_id`       | Most recent run where this review was observed        |
| `last_seen_at`           | Most recent time this review was observed             |
| `created_at`             | Database row creation timestamp                       |
| `updated_at`             | Database row update timestamp                         |

Primary key:

```text
review_pk
```

Unique key:

```text
(app_source_id, source_review_id)
```

Reason:

For Google Play, `source_review_id` maps to the raw review ID from the source. The schema uses `(app_source_id, source_review_id)` instead of only `source_review_id` to make the design safer across apps, countries, languages, and future sources.

---

### 4.5 `review_observations`

Purpose:

Stores run-level observations for each review.

This table answers:

* Did this review appear in this run?
* Was it newly inserted?
* Was it already known?
* Was an existing row updated?
* What did the raw source payload look like during that run?

Example fields:

| Field                     | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `observation_id`          | Primary key                                          |
| `run_target_id`           | Foreign key to `ingestion_run_targets`               |
| `review_pk`               | Foreign key to `reviews`                             |
| `source_review_id`        | Source review ID from the raw data                   |
| `fetched_at`              | Time this review was fetched                         |
| `row_number_in_fetch`     | Row order in the fetch result                        |
| `insert_status`           | Insert result for this review                        |
| `occurrence_count_in_run` | Number of times this review appeared in the same run |
| `raw_payload`             | Original source row stored as JSON                   |

Primary key:

```text
observation_id
```

Unique key:

```text
(run_target_id, source_review_id)
```

Insert status values:

```text
inserted
already_known
updated
```

Reason:

Recurring ingestion needs a way to track whether a review is new or already known without duplicating the canonical review record. This table keeps the run history separate from the clean review table.

---

### 4.6 `review_quality_flags`

Purpose:

Stores quality flags for each canonical review.

Example fields:

| Field                               | Description                                      |
| ----------------------------------- | ------------------------------------------------ |
| `review_pk`                         | Primary key and foreign key to `reviews`         |
| `raw_text_length`                   | Length of the original text                      |
| `cleaned_text_length`               | Length of the cleaned text                       |
| `normalized_content_hash`           | Hash for repeated-content detection              |
| `is_empty_after_cleaning`           | Whether text becomes empty after cleaning        |
| `is_short_text`                     | Whether text is very short                       |
| `is_low_signal`                     | Whether the review has limited analytical signal |
| `low_signal_reason`                 | Reason for low-signal flag                       |
| `is_repeated_generic_content`       | Whether content appears repeatedly               |
| `repeated_content_count_app`        | Repetition count within the same app             |
| `repeated_content_count_global`     | Repetition count across all apps                 |
| `is_missing_review_created_version` | Whether `review_created_version` is missing      |
| `is_missing_app_version`            | Whether `app_version` is missing                 |
| `has_developer_reply`               | Whether the review has a developer reply         |
| `quality_flag_version`              | Version of the flagging logic                    |
| `computed_at`                       | Time the flags were computed                     |

Primary key:

```text
review_pk
```

Reason:

The EDA showed that low-signal reviews and repeated generic content are important quality issues, but they do not necessarily make Google Play unusable as a source. These records should be preserved with flags so downstream filtering can stay flexible.

---

## 5. Deduplication Logic

The main deduplication key is:

```text
(app_source_id, source_review_id)
```

For Google Play, `source_review_id` is the raw source review ID.

The ingestion logic should work as follows:

1. Fetch reviews for each app/source during an ingestion run.
2. For each review, identify the source-level key:

```text
app_source_id + source_review_id
```

3. If the key does not already exist in `reviews`, insert the review as a new canonical review.
4. If the key already exists, do not insert a duplicate row into `reviews`.
5. For an existing review, update fields that may change over time, such as:

   * `thumbs_up_count`
   * `reply_content`
   * `replied_at`
   * `review_created_version`
   * `app_version`
   * `last_seen_at`
   * `last_seen_run_id`
6. Write one row into `review_observations` to record whether this review was:

   * `inserted`
   * `already_known`
   * `updated`

Repeated generic content should not be treated as duplicate reviews. For example, many different users may leave the same short text such as “Good app” or “Nice”. These should remain separate review records but should be flagged using content hash and repeated-content indicators.

Low-signal reviews should also not be deleted. They should be preserved with quality flags so downstream users can decide whether to include or exclude them.

---

## 6. Raw Text vs. Cleaned Text

The schema keeps both raw and cleaned text.

| Field             | Meaning                                                     |
| ----------------- | ----------------------------------------------------------- |
| `raw_content`     | Original review text from Google Play                       |
| `cleaned_content` | Normalized text used for quality checks and future analysis |

The cleaned text should be created with a simple and reproducible process:

1. Strip leading and trailing spaces.
2. Normalize repeated whitespace.
3. Keep the original meaning of the review.
4. Avoid aggressive cleaning that may remove useful signal.

A normalized content hash can be created from the cleaned text:

```text
normalized_content_hash = SHA256(normalized cleaned text)
```

This hash supports repeated-content detection.

---

## 7. Timestamp Design

The schema keeps multiple timestamps because they answer different questions.

| Field                        | Meaning                                            |
| ---------------------------- | -------------------------------------------------- |
| `review_created_at`          | When the user review was created on Google Play    |
| `replied_at`                 | When the developer reply was created, if available |
| `started_at` / `finished_at` | When an ingestion run started and ended            |
| `fetched_at`                 | When this specific review was fetched in a run     |
| `first_seen_at`              | When this review first entered our database        |
| `last_seen_at`               | Most recent time this review was observed again    |

This design makes the recurring pipeline traceable over time.

---

## 8. App Version Fields

Google Play review output may include app version-related fields. The schema stores them as nullable text fields:

```text
review_created_version
app_version
```

These fields should not be required because version coverage may be incomplete. Missing version values are tracked through quality flags:

```text
is_missing_review_created_version
is_missing_app_version
```

Reason:

Version information is useful for future analysis, but missing version fields should not cause otherwise valid reviews to be dropped.

---

## 9. Quality Flag Logic

The first version of quality flags can use simple, explainable rules.

Example logic:

| Flag                                | Example Rule                                     |
| ----------------------------------- | ------------------------------------------------ |
| `is_empty_after_cleaning`           | Cleaned text is empty                            |
| `is_short_text`                     | Cleaned text length is below a minimum threshold |
| `is_low_signal`                     | Review is empty, very short, or generic          |
| `is_repeated_generic_content`       | Same normalized text appears many times          |
| `is_missing_review_created_version` | `review_created_version` is null                 |
| `is_missing_app_version`            | `app_version` is null                            |
| `has_developer_reply`               | `reply_content` is not null                      |

The exact thresholds can be adjusted later. For example, the first version can define short text as fewer than 10 characters after cleaning.

The schema includes `quality_flag_version` so changes to flagging rules can be tracked over time.

---

## 10. Design Trade-Offs

### Trade-off 1: Canonical review table plus observation table

The schema separates canonical reviews from run observations.

Benefit:

* avoids duplicate review records,
* keeps recurring run history,
* supports first-seen and last-seen tracking.

Cost:

* slightly more complex than a single flat table.

This trade-off is reasonable because recurring ingestion requires traceability.

---

### Trade-off 2: Repeated content is flagged, not removed

Repeated generic content is not the same as duplicate review IDs.

Benefit:

* avoids incorrectly deleting valid reviews from different users,
* allows downstream filtering based on the analysis use case.

Cost:

* repeated low-signal reviews remain in the database.

This is acceptable because the quality flags make the issue explicit.

---

### Trade-off 3: App version fields are nullable

Version fields are useful but may be incomplete.

Benefit:

* preserves app version data when available,
* does not reject valid reviews when version fields are missing.

Cost:

* downstream analysis must handle missing version values.

This matches the EDA findings.

---

### Trade-off 4: Raw payload can be stored in observations

The `review_observations` table can store the original source row as JSON.

Benefit:

* preserves source-level details,
* helps debug scraper output changes,
* supports future fields without immediate schema migration.

Cost:

* increases storage size.

For the first recurring pilot, traceability is more important than minimizing storage.

---

## 11. Downstream Analysis Support

The schema supports future analysis such as:

* rating distribution by app,
* review volume by collection date,
* review volume by source review date,
* new versus already-known review counts,
* low-signal review rate,
* repeated generic content rate,
* app version coverage,
* review length distribution,
* developer reply coverage,
* review trends over time.

An analysis-ready database view can combine app metadata, review records, and quality flags for easier downstream use.

---

## 12. Summary

This schema is designed to support the first recurring Google Play ingestion pilot.

It keeps the structure:

* clean, by separating source metadata, runs, reviews, observations, and quality flags;
* traceable, by preserving run IDs, timestamps, first-seen and last-seen fields;
* extensible, by using source-level metadata, nullable version fields, raw payload storage, and versioned quality flags.

The design also preserves data quality issues instead of removing them. Low-signal reviews, repeated generic content, and missing version fields are stored with explicit flags, making the data more useful for downstream filtering and analysis.
