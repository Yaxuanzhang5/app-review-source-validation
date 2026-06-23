# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to test whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, and basic exploratory/data quality analysis.

Google Play is tested as the primary source. iOS App Store public RSS feed is tested as a secondary source.

## Project Purpose

This validation focuses on:

- access method
- review volume
- available metadata fields
- pagination and batching
- duplicate handling
- freshness
- field consistency
- request failures
- exploratory analysis
- data quality issues
- repeated-run comparison
- final source recommendation

## Final Module Status

This module has completed three validation runs: Run 1, Run 2, and Run 3.

The repository includes:

- three validation notebooks
- Run 1, Run 2, and Run 3 summary outputs
- repeated-run comparison outputs
- three-run source summary
- final module conclusion report

The final synthesized conclusion is that Google Play should be treated as the primary source for the recurring review ingestion pilot, while iOS App Store public RSS should remain a secondary source.

Google Play was stable across all three runs. It consistently collected 6,000 reviews per run, with 2,000 reviews per app, 0 duplicate rows within each run, stable review IDs, consistent schema across repeated comparisons, and new review capture in both Run 2 and Run 3.

iOS App Store public RSS was also technically usable, but it was less consistent than Google Play. It depended more on country/page combinations, had duplicate rows across runs, and collected 6,800 reviews in Run 3 compared with 7,000 reviews in Run 1 and Run 2.

The current recommendation is to use Google Play as the main recurring ingestion source and keep iOS as a supplementary source for additional coverage.

## Test Apps

The validation uses three mainstream apps:

- YouTube
- TikTok
- Spotify

Google Play was tested using US / English newest reviews.

iOS App Store public RSS was tested across five countries:

- US
- UK
- Canada
- Australia
- India

For iOS, pages 1 through 10 were requested for each app-country pair.

## Current Runs

This repository includes three completed validation runs.

### Run 1

Run 1 was a clean restart of the validation workflow so the notebook, summary outputs, and findings could be saved consistently.

Run 1 includes:

- Google Play review collection
- iOS App Store public RSS review collection
- collection summary
- validation summary
- duplicate check
- source-level comparison
- rating distribution
- review length analysis
- missing field analysis
- app version coverage
- language detection
- Run 1 findings report

### Run 2

Run 2 repeats the same collection and analysis workflow to test recurring ingestion feasibility.

Run 2 includes:

- repeated Google Play collection
- repeated iOS App Store public RSS collection
- Run 2 validation summaries
- Run 2 exploratory and data quality checks
- Google Play Run 1 vs Run 2 comparison
- iOS Run 1 vs Run 2 comparison
- Run 2 findings report

### Run 3

Run 3 repeats the workflow again to add one more repeated-run check and wrap up the current source validation module.

Run 3 includes:

- repeated Google Play collection
- repeated iOS App Store public RSS collection
- Run 3 validation summaries
- Run 3 exploratory and data quality checks
- Google Play Run 2 vs Run 3 comparison
- iOS Run 2 vs Run 3 comparison
- three-run source summary
- Google Play repeated-run summary
- iOS repeated-run summary
- final module conclusion summary
- synthesized module conclusion report

## Google Play Run Results

Google Play performed strongly across all three runs.

### Google Play Run 1

Summary:

- 6,000 total Google Play reviews collected
- 2,000 reviews per app
- 3 apps tested
- 0 failed app-level requests
- 6,000 unique review keys
- 0 duplicate rows

Core fields such as review ID, user name, review text, rating, thumbs-up count, and review date were complete.

App version and developer reply fields were partially missing, which is expected because not every review has an app version or developer response.

### Google Play Run 2

Summary:

- 6,000 total Google Play reviews collected
- 2,000 reviews per app
- 3 apps tested
- 0 failed app-level requests
- 6,000 unique review keys
- 0 duplicate rows

This confirmed that Google Play collection was stable across repeated runs.

### Google Play Run 3

Summary:

- 6,000 total Google Play reviews collected
- 2,000 reviews per app
- 3 apps tested
- 0 failed app-level requests
- 6,000 unique review keys
- 0 duplicate rows

This further confirmed that Google Play can support stable repeated collection.

## iOS App Store Run Results

The iOS App Store public RSS feed was also technically accessible across the three runs, but it was less consistent than Google Play.

### iOS App Store Run 1

Summary:

- 7,000 total iOS reviews collected
- 3 apps tested
- 5 countries tested
- 10 pages requested per app-country pair
- 14 out of 15 app-country pairs returned usable reviews
- TikTok India returned 0 reviews with 10 empty pages
- 6,899 unique review keys
- 101 duplicate rows
- about 1.44% duplicate rate

This showed that iOS country and page rotation can increase review coverage, but coverage is still less consistent than Google Play.

### iOS App Store Run 2

Summary:

- 7,000 total iOS reviews collected
- 3 apps tested
- 5 countries tested
- 10 pages requested per app-country pair
- TikTok India again returned 0 reviews
- 6,795 unique review keys
- 205 duplicate rows
- about 2.93% duplicate rate

This confirmed that iOS can support repeated collection, but duplicate handling and country/page coverage checks are necessary.

### iOS App Store Run 3

Summary:

- 6,800 total iOS reviews collected
- 3 apps tested
- 5 countries tested
- 10 pages requested per app-country pair
- 6,750 unique review keys
- 50 duplicate rows
- about 0.74% duplicate rate

Run 3 showed that iOS remained technically usable, but the collected volume changed from 7,000 to 6,800 reviews. This confirms that iOS coverage can vary more across runs than Google Play.

## Repeated-Run Comparison

The repeated-run comparison provides useful evidence for recurring ingestion feasibility.

The comparison checks:

- new review counts
- overlap with the previous run
- duplicate behavior across runs
- schema consistency
- newest review timestamp
- request stability

## Google Play Repeated-Run Comparison

For Google Play, repeated-run results were stable and useful for recurring ingestion.

### Run 1 vs Run 2

- YouTube captured 1,238 new reviews in Run 2, with 762 overlapping reviews.
- TikTok captured 620 new reviews in Run 2, with 1,380 overlapping reviews.
- Spotify captured 695 new reviews in Run 2, with 1,305 overlapping reviews.

### Run 2 vs Run 3

- YouTube captured 1,402 new reviews in Run 3, with 598 overlapping reviews.
- TikTok captured 596 new reviews in Run 3, with 1,404 overlapping reviews.
- Spotify captured 694 new reviews in Run 3, with 1,306 overlapping reviews.

All Google Play repeated-run comparisons showed the same schema across runs.

This is a positive result for recurring ingestion. Google Play can repeatedly return stable batch sizes while also capturing new reviews across runs. The overlap is expected because the collection pulls the newest reviews, so some recent reviews from the previous run will still appear in the next run.

## iOS App Store Repeated-Run Comparison

For iOS, repeated-run results showed that the source is technically usable, but less consistent than Google Play.

iOS captured both overlapping and new reviews across app-country pairs. Most app-country pairs kept the same schema across runs.

However, iOS had more variation:

- some app-country pairs had very high overlap
- some app-country pairs captured more new reviews
- some pairs returned fewer reviews in Run 3
- duplicate rows appeared in each run
- TikTok India was unavailable or inconsistent across runs

This suggests that iOS can support repeated collection, but it depends more heavily on country/page combinations and requires stronger duplicate and empty-page handling.

## Source-Level Conclusion

Both Google Play and iOS passed the basic technical access test.

Google Play is cleaner for recurring ingestion because it returned stable review IDs, no duplicate rows within each run, strong volume, consistent metadata, and new review capture across runs.

iOS returned useful review volume, but it required country/page rotation and still had empty or incomplete coverage for some app-country combinations. iOS also had duplicate rows in all runs and showed more volume variation by Run 3.

Current conclusion:

Google Play should remain the primary source for the repeated ingestion pilot. iOS can remain a secondary source for additional coverage.

## Exploratory and Data Quality Analysis

All runs include basic exploratory and statistical analysis.

The analysis checks:

- rating distribution
- review length
- missing fields
- app version coverage
- detected language
- duplicate patterns
- source-level data quality issues

Main observations:

- Both sources contain a mix of positive and negative reviews.
- Many reviews are either 1-star or 5-star.
- iOS reviews were generally longer than Google Play reviews.
- Google Play core fields were complete.
- Google Play app version and developer reply fields had missing values.
- iOS checked fields were mostly complete for collected reviews.
- Language detection shows mostly English reviews, but some reviews were detected as other languages.
- Language detection should be treated as a rough data quality flag because short reviews can be misclassified.

## Final Recommendation

After three runs, Google Play is the strongest candidate source for a small recurring review ingestion pilot.

Google Play is recommended as the primary path because it provides:

- stable repeated collection
- strong and consistent review volume
- stable review IDs
- clean within-run duplicate handling
- schema consistency across runs
- clear new review capture across repeated runs
- usable metadata for downstream analysis

iOS App Store public RSS should remain a secondary source.

iOS is useful for additional country-level coverage, but it should not be the main ingestion path because it has more duplicate rows, stronger country/page dependence, and less consistent collection volume.

If this work moves into the next stage, the recommended next step is to convert the notebook workflow into reusable scripts and schedule additional recurring runs to monitor freshness, failures, schema stability, and duplicate behavior over time.

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
│   └── App_Review_Source_Validation_Run3.ipynb
│
├── outputs/
│   └── summaries/
│       ├── google_play_collection_summary_run1
│       ├── google_play_validation_summary_run1
│       ├── google_play_duplicate_summary_run1
│       ├── ios_collection_summary_run1
│       ├── ios_validation_summary_run1
│       ├── ios_duplicate_summary_run1
│       ├── source_comparison_run1
│       ├── rating_distribution_run1
│       ├── review_length_summary_run1
│       ├── missing_summary_run1
│       ├── app_version_coverage_run1
│       ├── language_summary_run1
│       ├── google_play_collection_summary_run2
│       ├── google_play_validation_summary_run2
│       ├── google_play_duplicate_summary_run2
│       ├── ios_collection_summary_run2
│       ├── ios_validation_summary_run2
│       ├── ios_duplicate_summary_run2
│       ├── source_comparison_run2
│       ├── rating_distribution_run2
│       ├── review_length_summary_run2
│       ├── missing_summary_run2
│       ├── app_version_coverage_run2
│       ├── language_summary_run2
│       ├── google_play_run1_vs_run2_comparison
│       ├── ios_run1_vs_run2_comparison
│       ├── google_play_collection_summary_run3
│       ├── google_play_validation_summary_run3
│       ├── google_play_duplicate_summary_run3
│       ├── ios_collection_summary_run3
│       ├── ios_validation_summary_run3
│       ├── ios_duplicate_summary_run3
│       ├── source_comparison_run3
│       ├── rating_distribution_run3
│       ├── review_length_summary_run3
│       ├── missing_summary_run3
│       ├── app_version_coverage_run3
│       ├── language_summary_run3
│       ├── google_play_run2_vs_run3_comparison
│       ├── ios_run2_vs_run3_comparison
│       ├── three_run_source_summary
│       ├── google_play_repeated_run_summary
│       ├── ios_repeated_run_summary
│       └── module_conclusion_summary
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

Raw and processed review-level data are saved locally in Google Drive during the notebook runs. They are not uploaded to GitHub in this version because the summary outputs are enough for review and the raw files are larger.

## Key Files for Review

The most important files to review are:

- `notebooks/App_Review_Source_Validation_Run3.ipynb`
- `reports/synthesized_module_conclusion_2026_06_23.md`
- `outputs/summaries/three_run_source_summary_2026_06_23.csv`
- `outputs/summaries/google_play_repeated_run_summary_2026_06_23.csv`
- `outputs/summaries/ios_repeated_run_summary_2026_06_23.csv`
- `outputs/summaries/module_conclusion_summary_2026_06_23.csv`
