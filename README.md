# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to test whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, freshness tracking, and basic exploratory analysis.

Google Play is tested as the primary source. iOS App Store public RSS feed is tested as a secondary source.

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

## Current Runs

This repository includes two completed validation runs.

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

The repeated-run comparison checks new review counts, overlap with Run 1, duplicate rates across runs, schema consistency, failures, and freshness patterns.

## Test Apps

The validation uses three mainstream apps:

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

## Google Play Run 1 Result

Google Play performed strongly in Run 1.

Summary:

* 6,000 total Google Play reviews collected
* 2,000 reviews per app
* 3 apps tested
* 0 failed app-level requests
* 6,000 unique review keys
* 0 duplicate rows

Core fields such as review ID, user name, review text, rating, thumbs-up count, and review date were complete.

App version and developer reply fields were partially missing, which is expected because not every review has an app version or developer response.

Based on Run 1, Google Play looked like the stronger primary source for repeated collection testing.

## iOS App Store Run 1 Result

The iOS App Store public RSS feed was also technically accessible in Run 1.

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

This shows that iOS country and page rotation can increase review coverage, but coverage is still less consistent than Google Play.

iOS is feasible as a secondary source, but duplicate handling and empty-page tracking are necessary.

## Google Play Run 2 Result

Google Play remained stable in Run 2.

Summary:

* 6,000 total Google Play reviews collected
* 2,000 reviews per app
* 3 apps tested
* 0 failed app-level requests
* 6,000 unique review keys
* 0 duplicate rows

This confirms that Google Play collection is stable across repeated runs.

## iOS App Store Run 2 Result

The iOS App Store public RSS feed was also stable in Run 2.

Summary:

* 7,000 total iOS reviews collected
* 3 apps tested
* 5 countries tested
* 10 pages requested per app-country pair
* TikTok India again returned 0 reviews
* 6,891 unique review keys
* 109 duplicate rows
* about 1.56% duplicate rate

This confirms that iOS can also support repeated collection, but duplicate handling and country/page coverage checks are still necessary.

## Run 1 vs Run 2 Comparison

The repeated-run comparison provides useful evidence for recurring ingestion feasibility.

### Google Play Comparison

For Google Play, Run 2 captured both overlapping reviews and new reviews compared with Run 1.

This is expected for newest-review collection and is a positive sign for recurring ingestion.

Google Play Run 1 vs Run 2 result:

* YouTube had 1,238 new reviews in Run 2 and 762 overlapping reviews with Run 1.
* TikTok had 612 new reviews in Run 2 and 1,388 overlapping reviews with Run 1.
* Spotify had 695 new reviews in Run 2 and 1,305 overlapping reviews with Run 1.
* All three Google Play app comparisons showed the same schema across runs.

This means Google Play can support repeated collection while preserving enough stable structure for duplicate handling and cross-run comparison.

### iOS Comparison

For iOS, Run 2 also captured both overlapping and new reviews at the app-country level.

Most app-country pairs had the same schema across runs. Some combinations had high overlap, while several US pairs had more new reviews, such as YouTube US, TikTok US, and Spotify US.

TikTok India remained unavailable in Run 2, which confirms that some iOS app-country pairs can return empty results even when the request itself does not fail.

This suggests that iOS can support repeated collection, but it has more duplicate and coverage issues than Google Play.

## Source-Level Conclusion

Both Google Play and iOS passed the basic technical access test.

Google Play is cleaner for recurring ingestion because it returned stable review IDs, no duplicate rows within each run, strong volume, consistent metadata, and new review capture across runs.

iOS returned useful review volume, but it required country/page rotation and still had empty results for one app-country pair. iOS also had some duplicate rows in both runs.

Current conclusion:

Google Play should remain the primary source for the repeated ingestion pilot. iOS can remain a secondary source for additional coverage.

## Exploratory and Data Quality Analysis

Both runs include basic exploratory and statistical analysis.

The analysis checks:

* rating distribution
* review length
* missing fields
* app version coverage
* detected language
* duplicate patterns
* source-level data quality issues

Main observations:

* Both sources contain a mix of positive and negative reviews.
* Many reviews are either 1-star or 5-star.
* iOS reviews were generally longer than Google Play reviews in these runs.
* Google Play core fields were complete.
* Google Play app version and developer reply fields had missing values.
* iOS checked fields were complete for the collected reviews.
* Language detection shows mostly English reviews, but some reviews were detected as other languages.
* Language detection should be treated as a rough data quality flag because short reviews can be misclassified.

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
│   └── App_Review_Source_Validation_Run2.ipynb
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
│       └── ios_run1_vs_run2_comparison
│
├── reports/
│   ├── run1_findings
│   └── run2_findings
│
└── data/
    ├── raw/
    └── processed/
```

Raw and processed review-level data are saved locally in Google Drive during the notebook runs. They are not uploaded to GitHub in this version because the summary outputs are enough for review and the raw files are larger.

## Current Conclusion After Run 2

After two runs, Google Play remains the strongest candidate source for a recurring app review ingestion pilot.

Google Play showed:

* stable repeated collection
* 6,000 reviews collected in each run
* 2,000 reviews per app
* 0 duplicate rows within each run
* stable review IDs
* same schema across runs
* new review capture in Run 2

In the Google Play Run 1 vs Run 2 comparison:

* YouTube had 1,238 new reviews in Run 2 and 762 overlapping reviews with Run 1.
* TikTok had 612 new reviews in Run 2 and 1,388 overlapping reviews with Run 1.
* Spotify had 695 new reviews in Run 2 and 1,305 overlapping reviews with Run 1.

iOS App Store public RSS also remained technically usable, but it is better treated as a secondary source because it requires country/page rotation and has more duplicate and coverage issues.

The next step would be to continue one or two additional runs if more evidence is needed, but the current Run 1 and Run 2 results already show that Google Play is feasible for a small recurring review ingestion pilot.
