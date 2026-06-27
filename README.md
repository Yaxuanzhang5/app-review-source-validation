# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to test whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, and exploratory/data quality analysis.

Google Play is tested as the primary source. iOS App Store public RSS feed is tested as a secondary source.

## Latest Update: Run 4 Google Play 10k+ Review EDA

After completing Run 1, Run 2, and Run 3 for source validation and repeated-run comparison, I added Run 4 to focus more deeply on Google Play review content and data quality before moving into SQL/database design.

Run 4 collected a larger Google Play sample:

* 12,000 total Google Play reviews
* 10 mainstream apps
* 1,200 reviews per app
* 12,000 unique review IDs
* review date range: 2026-05-28 17:50:21 to 2026-06-25 20:57:50

Run 4 checks:

* rating distribution
* review length
* language patterns
* missing fields
* duplicate review IDs
* duplicate review content
* near-duplicate review text
* low-signal reviews
* timestamps
* app version coverage
* basic data quality flags

The Run 4 conclusion is that Google Play remains the stronger primary source for the first recurring ingestion pilot. The data is structurally clean enough for downstream analysis and later database design, but the future pipeline should track low-signal reviews, repeated generic text, incomplete app version fields, detected language, timestamps, and optional developer reply fields.

## Project Purpose

This validation focuses on:

* access method
* review volume
* available metadata fields
* pagination and batching
* duplicate handling
* freshness
* field consistency
* request failures
* exploratory analysis
* data quality issues
* repeated-run comparison
* final source recommendation
* deeper Google Play content/data quality review

## Current Module Status

This repository now includes four validation/EDA runs.

Run 1, Run 2, and Run 3 validate Google Play and iOS App Store public review sources for recurring ingestion feasibility. These runs test collection stability, duplicate handling, schema consistency, freshness, and repeated-run behavior.

Run 4 extends the work by collecting a larger Google Play review sample and checking whether the collected review content is rich and clean enough to support downstream analysis, modeling, and SQL/database design.

The current recommendation is still to use Google Play as the main recurring ingestion source and keep iOS App Store public RSS as a supplementary source.

## Test Apps

### Run 1 to Run 3

The first three validation runs use three mainstream apps:

* YouTube
* TikTok
* Spotify

Google Play was tested using US / English newest reviews.

iOS App Store public RSS was tested across five countries:

* US
* UK
* Canada
* Australia
* India

For iOS, pages 1 through 10 were requested for each app-country pair.

### Run 4

Run 4 uses a larger Google Play app sample:

* YouTube
* TikTok
* Instagram
* Spotify
* Uber
* DoorDash
* Duolingo
* Netflix
* Airbnb
* Walmart

Google Play was again collected using US / English settings.

## Current Runs

This repository includes four completed runs.

### Run 1

Run 1 was a clean restart of the validation workflow so the notebook, summary outputs, and findings could be saved consistently.

Run 1 includes:

* Google Play review collection
* iOS App Store public RSS review collection
* collection summary
* validation summary
* duplicate check
* source-level comparison
* rating distribution
* review length analysis
* missing field analysis
* app version coverage
* language detection
* Run 1 findings report

### Run 2

Run 2 repeats the same collection and analysis workflow to test recurring ingestion feasibility.

Run 2 includes:

* repeated Google Play collection
* repeated iOS App Store public RSS collection
* Run 2 validation summaries
* Run 2 exploratory and data quality checks
* Google Play Run 1 vs Run 2 comparison
* iOS Run 1 vs Run 2 comparison
* Run 2 findings report

### Run 3

Run 3 repeats the workflow again to add one more repeated-run check and wrap up the current source validation module.

Run 3 includes:

* repeated Google Play collection
* repeated iOS App Store public RSS collection
* Run 3 validation summaries
* Run 3 exploratory and data quality checks
* Google Play Run 2 vs Run 3 comparison
* iOS Run 2 vs Run 3 comparison
* three-run source summary
* Google Play repeated-run summary
* iOS repeated-run summary
* final module conclusion summary
* synthesized module conclusion report

### Run 4

Run 4 focuses on deeper Google Play review EDA and data quality.

Run 4 includes:

* 10-app Google Play review collection
* 12,000 total Google Play reviews
* app metadata check
* collection log
* rating distribution
* review length analysis
* missing field analysis
* duplicate review ID check
* duplicate review content check
* near-duplicate review text check
* low-signal review flagging
* language pattern check
* timestamp coverage check
* app version coverage check
* other data quality flags
* shareable cleaned review-level file with hashed review IDs
* summary output tables and figures

## Google Play Run Results

Google Play performed strongly across all validation runs.

### Google Play Run 1

Summary:

* 6,000 total Google Play reviews collected
* 2,000 reviews per app
* 3 apps tested
* 0 failed app-level requests
* 6,000 unique review keys
* 0 duplicate rows

Core fields such as review ID, user name, review text, rating, thumbs-up count, and review date were complete.

App version and developer reply fields were partially missing, which is expected because not every review has an app version or developer response.

### Google Play Run 2

Summary:

* 6,000 total Google Play reviews collected
* 2,000 reviews per app
* 3 apps tested
* 0 failed app-level requests
* 6,000 unique review keys
* 0 duplicate rows

This confirmed that Google Play collection was stable across repeated runs.

### Google Play Run 3

Summary:

* 6,000 total Google Play reviews collected
* 2,000 reviews per app
* 3 apps tested
* 0 failed app-level requests
* 6,000 unique review keys
* 0 duplicate rows

This further confirmed that Google Play can support stable repeated collection.

### Google Play Run 4

Summary:

* 12,000 total Google Play reviews collected
* 1,200 reviews per app
* 10 apps tested
* 12,000 unique review IDs
* 0 duplicate review IDs
* 0 missing values in review ID, content, score, timestamp, and thumbs-up count
* review date range: 2026-05-28 17:50:21 to 2026-06-25 20:57:50
* average rating: 3.74
* median rating: 5.0

Run 4 confirms that Google Play not only works as a source for recurring collection, but also provides review data that is structured enough for downstream EDA, modeling preparation, and database design.

## iOS App Store Run Results

The iOS App Store public RSS feed was also technically accessible across the first three runs, but it was less consistent than Google Play.

### iOS App Store Run 1

Summary:

* 7,000 total iOS reviews collected
* 3 apps tested
* 5 countries tested
* 10 pages requested per app-country pair
* 14 out of 15 app-country pairs returned usable reviews
* TikTok India returned 0 reviews with 10 empty pages
* 6,899 unique review keys
* 101 duplicate rows
* about 1.44% duplicate rate

This showed that iOS country and page rotation can increase review coverage, but coverage is still less consistent than Google Play.

### iOS App Store Run 2

Summary:

* 7,000 total iOS reviews collected
* 3 apps tested
* 5 countries tested
* 10 pages requested per app-country pair
* TikTok India again returned 0 reviews
* 6,795 unique review keys
* 205 duplicate rows
* about 2.93% duplicate rate

This confirmed that iOS can support repeated collection, but duplicate handling and country/page coverage checks are necessary.

### iOS App Store Run 3

Summary:

* 6,800 total iOS reviews collected
* 3 apps tested
* 5 countries tested
* 10 pages requested per app-country pair
* 6,750 unique review keys
* 50 duplicate rows
* about 0.74% duplicate rate

Run 3 showed that iOS remained technically usable, but the collected volume changed from 7,000 to 6,800 reviews. This confirms that iOS coverage can vary more across runs than Google Play.

## Repeated-Run Comparison

The repeated-run comparison provides useful evidence for recurring ingestion feasibility.

The comparison checks:

* new review counts
* overlap with the previous run
* duplicate behavior across runs
* schema consistency
* newest review timestamp
* request stability

## Google Play Repeated-Run Comparison

For Google Play, repeated-run results were stable and useful for recurring ingestion.

### Run 1 vs Run 2

* YouTube captured 1,238 new reviews in Run 2, with 762 overlapping reviews.
* TikTok captured 620 new reviews in Run 2, with 1,380 overlapping reviews.
* Spotify captured 695 new reviews in Run 2, with 1,305 overlapping reviews.

### Run 2 vs Run 3

* YouTube captured 1,402 new reviews in Run 3, with 598 overlapping reviews.
* TikTok captured 596 new reviews in Run 3, with 1,404 overlapping reviews.
* Spotify captured 694 new reviews in Run 3, with 1,306 overlapping reviews.

All Google Play repeated-run comparisons showed the same schema across runs.

This is a positive result for recurring ingestion. Google Play can repeatedly return stable batch sizes while also capturing new reviews across runs. The overlap is expected because the collection pulls the newest reviews, so some recent reviews from the previous run will still appear in the next run.

## iOS App Store Repeated-Run Comparison

For iOS, repeated-run results showed that the source is technically usable, but less consistent than Google Play.

iOS captured both overlapping and new reviews across app-country pairs. Most app-country pairs kept the same schema across runs.

However, iOS had more variation:

* some app-country pairs had very high overlap
* some app-country pairs captured more new reviews
* some pairs returned fewer reviews in Run 3
* duplicate rows appeared in each run
* TikTok India was unavailable or inconsistent across runs

This suggests that iOS can support repeated collection, but it depends more heavily on country/page combinations and requires stronger duplicate and empty-page handling.

## Run 4 Google Play Data Quality Findings

Run 4 was added after the repeated-run validation because the next question was not only whether Google Play can return review data, but whether the content and quality of that data are strong enough for downstream work.

### Core Field Completeness

The core fields are complete and usable:

* review ID: 0% missing
* review content: 0% missing
* rating score: 0% missing
* timestamp: 0% missing
* thumbs-up count: 0% missing
* review IDs: 12,000 unique IDs across 12,000 rows

This supports using review ID and timestamp as key fields for recurring ingestion.

### Rating Distribution

The rating distribution has meaningful variation.

Overall rating summary:

* 1-star reviews: 2,859 reviews, 23.82%
* 2-star reviews: 547 reviews, 4.56%
* 3-star reviews: 573 reviews, 4.78%
* 4-star reviews: 844 reviews, 7.03%
* 5-star reviews: 7,177 reviews, 59.81%

The data is heavily concentrated in 5-star reviews, but 1-star reviews are also a meaningful segment. This makes the data useful for app-level comparison and later modeling.

### Review Length

Review length varies strongly by app.

Examples:

* DoorDash has the longest average review length at about 111 characters.
* YouTube has the shortest average review length at about 43 characters.
* Overall average review length is about 75 characters.
* Overall median review length is 28 characters.

This means the dataset includes both detailed feedback and very short comments.

### Missing Fields

Missingness is mainly concentrated in optional or secondary fields:

* developer reply content missing: 81.51%
* developer reply timestamp missing: 81.51%
* appVersion missing: 17.66%
* reviewCreatedVersion missing: 17.66%

Developer reply missingness is expected because many reviews do not receive replies. App version fields are useful but incomplete, so version-level analysis should be treated as optional rather than required.

### Duplicate Review IDs and Repeated Content

There are no duplicate review IDs in Run 4.

However, repeated review text is common:

* exact duplicate content within the same app: 1,941 rows, 16.18%
* exact duplicate content globally: 2,464 rows, 20.53%

These repeated texts are mostly generic short reviews, such as “amazing,” “awesome,” or “best app.” This should be treated as a content quality issue, not a collection error.

### Near-Duplicate Content

The near-duplicate check used TF-IDF and cosine similarity with a 0.92 threshold.

Run 4 found:

* 16 near-duplicate review text pairs

This is small compared with the full dataset, but near-duplicate tracking should still be included as a future quality check.

### Low-Signal Reviews

Low-signal reviews are common.

Run 4 flagged:

* 4,741 low-signal reviews
* about 39.51% of the dataset

These reviews can still be useful for rating-level analysis, but they should be flagged or filtered for text modeling.

The apps with the highest low-signal shares include:

* YouTube
* TikTok
* Instagram
* Uber

### Language Patterns

US / English collection settings do not guarantee fully English review text.

Run 4 language summary:

* English detected: 6,897 reviews, 57.48%
* too short for reliable language detection: 4,042 reviews, 33.68%
* other or unknown language labels: remaining reviews

This means language detection should be kept as a data quality flag, especially for NLP or text modeling.

### Timestamp Coverage

Review timestamps are complete and usable.

Some high-volume apps returned 1,200 recent reviews within the same day, while Airbnb covered 28 days. This is not a problem; it shows that review velocity differs by app.

Timestamp availability supports recurring ingestion because future runs can compare records by review ID and timestamp.

### App Version Coverage

App version fields are useful but incomplete.

Examples:

* YouTube version coverage: 97.83%
* Walmart version coverage: 94.75%
* TikTok version coverage: 62.00%
* Instagram version coverage: 62.75%

Version-level analysis is possible, but it should not be treated as complete for every record.

## Source-Level Conclusion

Both Google Play and iOS passed the basic technical access test.

Google Play is cleaner for recurring ingestion because it returned stable review IDs, no duplicate rows within each of the first three repeated runs, strong volume, consistent metadata, and new review capture across repeated runs.

Run 4 adds more support for Google Play as the primary source because the larger Google Play sample also shows complete core fields, unique review IDs, usable timestamps, and manageable data quality issues.

iOS returned useful review volume, but it required country/page rotation and still had empty or incomplete coverage for some app-country combinations. iOS also had duplicate rows in all runs and showed more volume variation by Run 3.

Current conclusion:

Google Play should remain the primary source for the repeated ingestion pilot. iOS can remain a secondary source for additional coverage.

## Exploratory and Data Quality Analysis

All runs include exploratory and data quality analysis.

The analysis checks:

* rating distribution
* review length
* missing fields
* app version coverage
* detected language
* duplicate patterns
* source-level data quality issues
* repeated-run behavior
* low-signal reviews
* near-duplicate content

Main observations:

* Both sources contain a mix of positive and negative reviews.
* Many reviews are either 1-star or 5-star.
* iOS reviews were generally longer than Google Play reviews in the first three validation runs.
* Google Play core fields were complete.
* Google Play app version and developer reply fields had missing values.
* iOS checked fields were mostly complete for collected reviews.
* Language detection shows mostly English reviews, but some reviews are detected as other languages.
* Language detection should be treated as a rough data quality flag because short reviews can be misclassified.
* Run 4 shows that Google Play has many low-signal reviews, so downstream text modeling should keep quality flags.

## Final Recommendation

After four runs, Google Play is the strongest candidate source for a small recurring review ingestion pilot.

Google Play is recommended as the primary path because it provides:

* stable repeated collection
* strong and consistent review volume
* stable review IDs
* clean within-run duplicate handling
* schema consistency across repeated runs
* clear new review capture across repeated runs
* usable timestamps for recurring ingestion
* complete core review fields
* usable metadata for downstream analysis
* manageable data quality issues

iOS App Store public RSS should remain a secondary source.

iOS is useful for additional country-level coverage, but it should not be the main ingestion path because it has more duplicate rows, stronger country/page dependence, and less consistent collection volume.

If this work moves into the next stage, the recommended next step is to design the SQL/database schema around the observed Google Play fields and quality flags. Important fields to include are review ID, app ID, app name, content, score, timestamp, app version fields, detected language, low-signal flag, duplicate-content flag, and optional developer reply fields.

## Repository Structure

```text
app-review-source-validation/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── notebooks/
│   ├── App_Review_Source_Validation_Run1.ipynb
│   ├── App_Review_Source_Validation_Run2.ipynb
│   ├── App_Review_Source_Validation_Run3.ipynb
│   └── Google_Play_10k_Review_EDA_Data_Quality_Validation.ipynb
│
├── outputs/
│   ├── summaries/
│   │   ├── google_play_collection_summary_run1
│   │   ├── google_play_validation_summary_run1
│   │   ├── google_play_duplicate_summary_run1
│   │   ├── ios_collection_summary_run1
│   │   ├── ios_validation_summary_run1
│   │   ├── ios_duplicate_summary_run1
│   │   ├── source_comparison_run1
│   │   ├── rating_distribution_run1
│   │   ├── review_length_summary_run1
│   │   ├── missing_summary_run1
│   │   ├── app_version_coverage_run1
│   │   ├── language_summary_run1
│   │   ├── google_play_collection_summary_run2
│   │   ├── google_play_validation_summary_run2
│   │   ├── google_play_duplicate_summary_run2
│   │   ├── ios_collection_summary_run2
│   │   ├── ios_validation_summary_run2
│   │   ├── ios_duplicate_summary_run2
│   │   ├── source_comparison_run2
│   │   ├── rating_distribution_run2
│   │   ├── review_length_summary_run2
│   │   ├── missing_summary_run2
│   │   ├── app_version_coverage_run2
│   │   ├── language_summary_run2
│   │   ├── google_play_run1_vs_run2_comparison
│   │   ├── ios_run1_vs_run2_comparison
│   │   ├── google_play_collection_summary_run3
│   │   ├── google_play_validation_summary_run3
│   │   ├── google_play_duplicate_summary_run3
│   │   ├── ios_collection_summary_run3
│   │   ├── ios_validation_summary_run3
│   │   ├── ios_duplicate_summary_run3
│   │   ├── source_comparison_run3
│   │   ├── rating_distribution_run3
│   │   ├── review_length_summary_run3
│   │   ├── missing_summary_run3
│   │   ├── app_version_coverage_run3
│   │   ├── language_summary_run3
│   │   ├── google_play_run2_vs_run3_comparison
│   │   ├── ios_run2_vs_run3_comparison
│   │   ├── three_run_source_summary
│   │   ├── google_play_repeated_run_summary
│   │   ├── ios_repeated_run_summary
│   │   └── module_conclusion_summary
│   │
│   └── run4_google_play_10k_eda/
│       ├── googleplay_10k_eda_20260626_205621_app_metadata.csv
│       ├── googleplay_10k_eda_20260626_205621_collection_log.csv
│       ├── googleplay_10k_eda_20260626_205621_overall_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_app_level_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_overall_rating_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_rating_counts_by_app.csv
│       ├── googleplay_10k_eda_20260626_205621_rating_pct_by_app.csv
│       ├── googleplay_10k_eda_20260626_205621_review_length_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_missing_overall.csv
│       ├── googleplay_10k_eda_20260626_205621_missing_by_app.csv
│       ├── googleplay_10k_eda_20260626_205621_duplicate_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_duplicate_by_app.csv
│       ├── googleplay_10k_eda_20260626_205621_near_duplicate_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_low_signal_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_language_overall.csv
│       ├── googleplay_10k_eda_20260626_205621_timestamp_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_version_summary.csv
│       ├── googleplay_10k_eda_20260626_205621_quality_flags.csv
│       ├── googleplay_10k_eda_20260626_205621_main_summary_tables.xlsx
│       ├── googleplay_10k_eda_20260626_205621_run_manifest.json
│       ├── googleplay_10k_eda_20260626_205621_clean_reviews_with_features_shareable.csv
│       └── figures/
│           ├── googleplay_10k_eda_20260626_205621_overall_rating_distribution.png
│           ├── googleplay_10k_eda_20260626_205621_rating_distribution_by_app.png
│           ├── googleplay_10k_eda_20260626_205621_word_count_distribution.png
│           └── googleplay_10k_eda_20260626_205621_daily_review_counts.png
│
├── reports/
│   ├── run1_findings
│   ├── run2_findings
│   ├── run3_findings
│   └── synthesized_module_conclusion
│
└── data/
    ├── raw/
    └── processed/
```

Raw and processed review-level data are saved locally during notebook runs. They are not uploaded to GitHub because the summary outputs and shareable cleaned file are enough for review, and raw files may contain user-level fields.

## Key Files for Review

The most important files to review are:

* `notebooks/App_Review_Source_Validation_Run3.ipynb`
* `notebooks/Google_Play_10k_Review_EDA_Data_Quality_Validation.ipynb`
* `reports/synthesized_module_conclusion_2026_06_23.md`
* `outputs/summaries/three_run_source_summary_2026_06_23.csv`
* `outputs/summaries/google_play_repeated_run_summary_2026_06_23.csv`
* `outputs/summaries/ios_repeated_run_summary_2026_06_23.csv`
* `outputs/summaries/module_conclusion_summary_2026_06_23.csv`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_main_summary_tables.xlsx`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_run_manifest.json`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_clean_reviews_with_features_shareable.csv`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_quality_flags.csv`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_low_signal_summary.csv`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_duplicate_summary.csv`
* `outputs/run4_google_play_10k_eda/googleplay_10k_eda_20260626_205621_language_overall.csv`

## Data Sharing Note

The raw internal Google Play review file is not uploaded to GitHub because it may contain user-level fields such as usernames, user image links, and original review IDs.

For Run 4, the shareable cleaned file removes direct user-level fields and uses hashed review IDs.
