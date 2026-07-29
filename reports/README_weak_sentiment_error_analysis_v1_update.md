## Weak sentiment error analysis and cross-app transfer v1

### Scope

This phase diagnoses the rating-derived weak-sentiment baseline without tuning for a higher headline score. It includes:

- a 120-row manual review of baseline errors with additional three-star coverage;
- TF-IDF-only versus TF-IDF plus current engineered features on the same grouped split; and
- a strict two-app holdout using YouTube and DoorDash with zero exact text-group overlap.

### Main findings

1. In the 60 reviewed three-star errors, 40 were categorized as inconsistent with the rating-derived neutral label, 13 as mixed, 7 as unclear, and 0 as cleanly neutral.
2. The current engineered features changed macro F1 from 0.5892 to 0.5899 and neutral F1 from 0.1103 to 0.1146. This is not a material overall gain.
3. Strictly holding out YouTube and DoorDash reduced macro F1 from 0.5899 to 0.5611. YouTube and DoorDash also produced different app-level results.
4. The recommended priority is label design first, evaluation setup second, and feature design third.
5. A more complex model is not recommended until a manually labeled validation set separates star rating, text sentiment, and rating-text consistency.

### Main files

```text
inputs/
└── manual_error_annotations_v1.csv

notebooks/
└── Google_Play_Weak_Sentiment_Error_Analysis_v1.ipynb

outputs/
├── weak_sentiment_error_analysis_source_validation_v1.csv
├── weak_sentiment_feature_set_comparison_metrics_v1.csv
├── weak_sentiment_feature_set_class_metrics_v1.csv
├── weak_sentiment_feature_set_prediction_changes_v1.csv
├── weak_sentiment_manual_error_review_v1.csv
├── weak_sentiment_manual_error_category_summary_v1.csv
├── weak_sentiment_manual_error_by_weak_label_v1.csv
├── weak_sentiment_manual_text_by_weak_label_v1.csv
├── weak_sentiment_manual_rating_consistency_v1.csv
├── weak_sentiment_manual_error_by_direction_v1.csv
├── weak_sentiment_two_app_holdout_design_v1.csv
├── weak_sentiment_two_app_holdout_metrics_v1.csv
├── weak_sentiment_two_app_holdout_class_metrics_v1.csv
├── weak_sentiment_two_app_holdout_per_app_metrics_v1.csv
├── weak_sentiment_two_app_holdout_per_app_class_metrics_v1.csv
├── weak_sentiment_two_app_holdout_confusion_matrix_v1.csv
├── weak_sentiment_error_analysis_validation_checks_v1.csv
├── weak_sentiment_error_analysis_metadata_v1.json
└── weak_sentiment_error_analysis_output_manifest_v1.csv

reports/
├── google_play_weak_sentiment_error_analysis_v1_report.md
└── README_weak_sentiment_error_analysis_v1_update.md
```

### Reproduction

1. Keep `outputs/modeling_ready_weak_sentiment_v0.csv` and `outputs/review_features_v0.csv` in the repository.
2. Keep `inputs/manual_error_annotations_v1.csv` in the repository.
3. Open `notebooks/Google_Play_Weak_Sentiment_Error_Analysis_v1.ipynb`.
4. Run all cells in order.
5. The notebook verifies the upstream file hashes, reproduces the prior full-feature baseline, recreates the deterministic error sample, joins the fixed manual annotations, runs both feature-set models, runs the two-app holdout, validates every result, and regenerates the CSV, JSON, and Markdown deliverables.

### Interpretation guardrail

Manual category counts describe the designed error sample and are not estimates for all reviews. This remains exploratory work and is not a production sentiment system.
