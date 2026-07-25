## Rating-derived weak sentiment baseline v0

### Objective

This downstream exploratory layer uses the validated `review_features_v0.csv` table to derive weak sentiment labels from source ratings:

- 1–2 stars: `negative`
- 3 stars: `neutral`
- 4–5 stars: `positive`

The labels are weak labels and are not manually verified sentiment annotations.

### Leakage controls

The model excludes `score`, `rating_group`, and `low_rating_flag`. It also excludes app identity, developer-reply availability, collection dates, run IDs, app versions, and source-lag fields from model inputs. Exact normalized text groups are assigned to only one data split, and explicit written star-rating expressions are replaced with a generic token before modeling.

### Data and class distribution

- 34,601 review rows
- 10 apps
- 27,681 training rows
- 6,920 test rows
- negative: 9,948 (28.75%)
- neutral: 1,629 (4.71%)
- positive: 23,024 (66.54%)
- exact normalized-text overlap between train and test: 0

### Exploratory feature patterns

Negative reviews are longer and more likely to match issue-keyword indicators. Positive reviews are more likely to be short, low-signal, or repeated. These are descriptive patterns in the current snapshot rather than causal conclusions.

### Baseline model

A class-weighted linear support vector classifier uses TF-IDF word unigrams and bigrams plus selected deterministic review features. The model uses fixed `C=1.0` and no hyperparameter search.

| Model | Accuracy | Balanced accuracy | Macro F1 | Weighted F1 |
|---|---:|---:|---:|---:|
| Majority-class reference | 0.6655 | 0.3333 | 0.2664 | 0.5318 |
| Class-weighted LinearSVC | 0.8208 | 0.5867 | 0.5899 | 0.8196 |

The model performs substantially better than the majority-class reference on balanced accuracy and macro F1. Neutral-class performance remains limited because three-star reviews are rare and may express mixed sentiment.

### Main outputs

```text
notebooks/
└── Google_Play_Weak_Sentiment_Baseline_v0.ipynb

outputs/
├── modeling_ready_weak_sentiment_v0.csv
├── weak_sentiment_source_validation_v0.csv
├── weak_sentiment_class_distribution_v0.csv
├── weak_sentiment_feature_patterns_v0.csv
├── weak_sentiment_issue_patterns_v0.csv
├── weak_sentiment_app_distribution_v0.csv
├── weak_sentiment_model_metrics_v0.csv
├── weak_sentiment_classification_report_v0.csv
├── weak_sentiment_confusion_matrix_v0.csv
├── weak_sentiment_top_coefficients_v0.csv
├── weak_sentiment_test_predictions_sample_v0.csv
├── weak_sentiment_validation_checks_v0.csv
├── weak_sentiment_baseline_metadata_v0.json
└── weak_sentiment_output_manifest_v0.csv

reports/
├── figures/
│   ├── weak_sentiment_class_distribution_v0.png
│   ├── weak_sentiment_feature_patterns_v0.png
│   └── weak_sentiment_confusion_matrix_v0.png
├── google_play_weak_sentiment_baseline_v0_report.md
├── weak_sentiment_baseline_v0_model_card.md
└── README_weak_sentiment_baseline_v0_update.md
```

### Limitations

This is an exploratory baseline, not a production system. Ratings are weak labels, the neutral class is small, text and rating can disagree, heuristic fields can be noisy, and cross-app or future-time generalization has not been established.
