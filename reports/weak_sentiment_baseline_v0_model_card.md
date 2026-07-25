# Weak Sentiment Baseline v0 Model Card

## Model

Class-weighted linear support vector classifier (`LinearSVC`, `C=1.0`) using TF-IDF word unigrams and bigrams plus a small set of deterministic review-level features.

## Intended use

- exploratory comparison of rating-derived weak sentiment groups
- baseline error analysis
- demonstration of a downstream modeling-ready workflow
- identification of label-quality and class-imbalance issues

## Not intended for

- production sentiment classification
- customer-level decisions
- automated moderation
- app-quality ranking
- ground-truth sentiment labeling
- performance claims beyond the current 10-app snapshot

## Target

- 1–2 stars = negative
- 3 stars = neutral
- 4–5 stars = positive

The target is a weak label derived from rating, not a manually verified sentiment label.

## Leakage controls

- `score`, `rating_group`, and `low_rating_flag` excluded
- explicit star-rating expressions redacted to a generic token
- exact normalized text grouped into one train/test partition
- app identity and developer-reply availability excluded from model inputs
- run and collection fields excluded

## Evaluation snapshot

- Test rows: 6,920
- Accuracy: 0.8208
- Balanced accuracy: 0.5867
- Macro F1: 0.5899
- Weighted F1: 0.8196

## Main risk

The neutral class is small and weakly defined. Neutral recall and F1 are substantially lower than positive and negative performance.

## Required interpretation

Outputs represent associations with rating-derived labels in the current dataset. They do not establish true sentiment, causation, or production readiness.
