# README Update — Feature Engineering v0

Add the following project stage after monitoring threshold calibration.

## Lightweight feature engineering v0

The next project layer creates a transparent feature table from the validated cleaned Google Play review data. This version does not train a sentiment, topic, or machine-learning model.

The feature notebook preserves all 34,601 cleaned review rows across 10 apps and adds:

- review character and word counts
- low, middle, and high rating groups
- short-review and low-signal flags
- duplicate-identity validation and repeated-text indicators
- review and collection dates
- review age at first collection
- a conservative non-English status with an `undetermined` state
- developer-reply availability
- simple crash/bug, performance/loading, login/account, payment/billing, ads, update/version, and support/service indicators
- app-level review volume, average rating, rating shares, short/low-signal shares, reply share, language shares, and issue shares

The operating sequence remains ingestion, monitoring, and then feature generation. A hard monitoring failure stops downstream use. A warning is reviewed and documented but does not automatically invalidate a completed usable run.

Feature engineering outputs:

```text
notebooks/
└── Google_Play_Review_Feature_Engineering_v0.ipynb

outputs/
├── review_features_v0.csv
├── review_feature_sample_v0.csv
├── app_feature_aggregates_v0.csv
├── feature_definitions_v0.csv
├── feature_quality_assessment_v0.csv
├── feature_validation_checks_v0.csv
├── feature_engineering_source_validation_v0.csv
├── feature_issue_indicator_rates_v0.csv
├── feature_engineering_metadata_v0.json
└── feature_engineering_output_manifest_v0.csv

reports/
├── google_play_feature_engineering_v0_report.md
├── feature_engineering_v0_feature_dictionary.md
└── README_feature_engineering_v0_update.md
```

The most reliable v0 features are identifiers, score/rating group, timestamps, text length, and developer-reply presence. The language, low-signal, repeated-text, and keyword issue fields are documented heuristics and should be used for screening and EDA rather than final labels.
