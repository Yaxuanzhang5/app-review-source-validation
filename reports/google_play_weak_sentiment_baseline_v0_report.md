# Google Play Rating-Derived Weak Sentiment Baseline v0 Report

## Objective

This downstream baseline uses the validated Feature Engineering v0 review table to create rating-derived weak sentiment labels, compare selected feature patterns, prepare a clean modeling-ready dataset, and test one transparent linear model.

The work is exploratory and is not a production sentiment system.

## Weak-label definition

- 1–2 stars: `negative`
- 3 stars: `neutral`
- 4–5 stars: `positive`

These labels are derived from source ratings. They are not manually reviewed ground-truth sentiment annotations.

## Data

- Review rows: 34,601
- Apps: 10
- Training rows: 27,681
- Test rows: 6,920
- Exact normalized-text groups shared across train and test: 0
- Reviews with explicit written star-rating expressions redacted: 415

## Class distribution

| Weak label | Reviews | Share |
|---|---:|---:|
| Negative | 9,948 | 28.75% |
| Neutral | 1,629 | 4.71% |
| Positive | 23,024 | 66.54% |

The neutral class is substantially smaller than the negative and positive classes, so accuracy alone is not a sufficient evaluation measure.

## Selected feature patterns

| Pattern | Negative | Neutral | Positive |
|---|---:|---:|---:|
| Median review characters | 84 | 57 | 15 |
| Median review words | 16 | 11 | 3 |
| Short-review share | 16.24% | 26.64% | 58.73% |
| Low-signal share | 12.07% | 21.42% | 49.26% |
| Repeated-text share | 4.61% | 12.40% | 31.70% |
| Developer-reply share | 15.60% | 21.06% | 11.03% |
| Any issue-indicator share | 42.73% | 30.26% | 6.30% |

Negative reviews are longer and more likely to match at least one issue-keyword category. Positive reviews are much more likely to be short, low-signal, or repeated. These are descriptive associations in the collected snapshot and should not be treated as causal findings.

## Leakage controls

The target is derived from rating, so `score`, `rating_group`, and `low_rating_flag` are excluded from the modeling-ready dataset and model inputs.

Additional controls:

- app identity is excluded from the model to reduce app-specific rating-prior shortcuts
- developer-reply availability is excluded because it may be a post-review signal
- collection dates, run IDs, app versions, and source-lag fields are excluded
- exact normalized text groups are kept in only one split
- explicit star-rating expressions are replaced with a generic token before TF-IDF generation

## Baseline model

- Model: class-weighted `LinearSVC`
- Regularization: fixed `C=1.0`
- Hyperparameter search: none
- Text representation: TF-IDF word unigrams and bigrams
- Additional inputs: text-length, low-signal, repeated-text, language-group, and keyword issue-indicator features
- Reference: majority-class dummy classifier

## Evaluation

| Model | Accuracy | Balanced accuracy | Macro F1 | Weighted F1 |
|---|---:|---:|---:|---:|
| Majority-class reference | 0.6655 | 0.3333 | 0.2664 | 0.5318 |
| Class-weighted LinearSVC | 0.8208 | 0.5867 | 0.5899 | 0.8196 |

| Class | Precision | Recall | F1 | Test support |
|---|---:|---:|---:|---:|
| Negative | 0.7796 | 0.7412 | 0.7599 | 1,990 |
| Neutral | 0.1153 | 0.1138 | 0.1146 | 325 |
| Positive | 0.8855 | 0.9051 | 0.8952 | 4,605 |

The linear model improves substantially over the majority-class reference on balanced accuracy and macro F1. Performance is strongest for positive and negative reviews. Neutral-review performance remains weak, which is consistent with the small neutral class and the ambiguity of a rating-derived three-star label.

## Interpretation

The exported coefficient table shows the strongest directional associations for each class. These weights are useful for model inspection, but they are not causal explanations or universal sentiment rules.

## Limitations

1. Ratings are weak labels rather than manually verified sentiment.
2. Three-star reviews are rare and may contain mixed or ambiguous sentiment.
3. Review text and rating can disagree.
4. The snapshot covers 10 selected Google Play apps and one accumulated collection period.
5. Language and issue indicators are heuristics.
6. Exact duplicate text is group-separated, but near-duplicate phrasing may cross partitions.
7. All 10 apps appear in both training and test data; cross-app generalization is not established.
8. The model is not probability-calibrated and has not been externally validated.
9. No production monitoring, drift testing, fairness testing, or deployment work is included.
10. Coefficients reflect associations within this dataset, not causation.

## Conclusion

The baseline satisfies the current exploratory objective: it creates a clean leakage-controlled dataset, documents the weak-label assumption, shows class and feature patterns, and provides one transparent model with reproducible evaluation outputs. It should be treated as a starting point for error analysis and label-quality review rather than as a production sentiment classifier.
