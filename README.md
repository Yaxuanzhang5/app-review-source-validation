# App Review Source Validation

This project validates public app review sources for a potential recurring review ingestion pipeline.

The main goal is to test whether Google Play and iOS App Store public review sources can support repeated collection, duplicate handling, metadata checks, and basic exploratory analysis.

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

Google Play is tested as the primary source. iOS App Store public RSS feed is tested as a secondary source.

## Current Run

The current notebook is a clean Run 1 validation.

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

## Run 1 Test Apps

The validation uses three mainstream apps:

- YouTube
- TikTok
- Spotify

Google Play was tested using US / English newest reviews.

iOS was tested across five countries:

- US
- UK
- Canada
- Australia
- India

For iOS, pages 1 through 10 were requested for each app-country pair.

## Google Play Run 1 Result

Google Play performed strongly in Run 1.

Summary:

- 6,000 total Google Play reviews collected
- 2,000 reviews per app
- 3 apps tested
- 0 failed app-level requests
- 6,000 unique review keys
- 0 duplicate rows

Core fields such as review ID, user name, review text, rating, thumbs-up count, and review date were complete.

App version and developer reply fields were partially missing, which is expected because not every review has an app version or developer response.

Based on Run 1, Google Play is the stronger primary source for repeated collection testing.

## iOS App Store Run 1 Result

The iOS App Store public RSS feed was also technically accessible.

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

This shows that iOS country and page rotation can increase review coverage, but coverage is still less consistent than Google Play.

iOS is feasible as a secondary source, but duplicate handling and empty-page tracking are necessary.

## Source-Level Conclusion

Both Google Play and iOS passed the basic technical access test.

Google Play is cleaner for recurring ingestion because it returned stable review IDs, no duplicate rows in Run 1, strong volume, and consistent metadata.

iOS returned useful review volume, but it required country/page rotation and still had empty results for one app-country pair. iOS also had some duplicate rows.

Current conclusion:

Google Play should remain the primary source for the repeated ingestion pilot. iOS can remain a secondary source for additional coverage.

## Exploratory and Data Quality Analysis

Run 1 also includes basic exploratory and statistical analysis.

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
- iOS reviews were generally longer than Google Play reviews in this run.
- Google Play core fields were complete.
- Google Play app version and developer reply fields had missing values.
- iOS checked fields were complete for the collected reviews.
- Language detection shows mostly English reviews, but some reviews were detected as other languages.
- Language detection should be treated as a rough data quality flag because short reviews can be misclassified.

## Repository Structure

```text
app-review-source-validation/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── notebooks/
│   └── App_Review_Source_Validation_Run1.ipynb
│
├── outputs/
│   └── summaries/
│       ├── google_play_collection_summary
│       ├── google_play_validation_summary
│       ├── google_play_duplicate_summary
│       ├── ios_collection_summary
│       ├── ios_validation_summary
│       ├── ios_duplicate_summary
│       ├── source_comparison
│       ├── rating_distribution
│       ├── review_length_summary
│       ├── missing_summary
│       ├── app_version_coverage
│       └── language_summary
│
├── reports/
│   └── run1_findings
│
└── data/
    ├── raw/
    └── processed/
