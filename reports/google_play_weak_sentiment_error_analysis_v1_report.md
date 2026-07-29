# Google Play Weak Sentiment Error Analysis and Cross-App Transfer v1

## Objective

This phase investigates the rating-derived weak-sentiment baseline without changing the model family or tuning for a higher headline score. It addresses:

1. the composition of baseline errors, especially three-star reviews;
2. TF-IDF alone versus the current engineered feature set; and
3. transfer to two apps held out entirely from training.

## Continuity and controls

- Source reviews: 34,601
- Apps: 10
- Original grouped training rows: 27,681
- Original grouped test rows: 6,920
- Exact normalized-text groups shared in the original split: 0
- Rating mapping retained: 1–2 negative, 3 neutral, 4–5 positive
- Direct star-rating expressions remain redacted in model text
- Model retained: class-weighted `LinearSVC`, fixed `C=1.0`
- TF-IDF retained: word unigrams and bigrams, maximum 6,000 features
- Hyperparameter search: none

## Manual error review

The full-feature baseline made 1,240 errors on the 6,920-row test split. The manual review contains:

- 90-row balanced core: 30 errors from each weak-label class
- 30 additional three-star errors
- 120 unique reviewed errors in total
- equal sampling from each wrong prediction direction within each weak-label class
- app round-robin selection within each direction

One reviewer used the original cleaned review text and source rating. The output records a text category, rating-consistency assessment, John's requested primary category, and a short rationale for every sampled review.

| Primary category | Count |
|---|---:|
| Neutral | 0 |
| Mixed | 23 |
| Positive | 10 |
| Negative | 17 |
| Unclear | 18 |
| Inconsistent with rating | 52 |

### Three-star focus

Among the 60 direction-balanced three-star errors:

- inconsistent with rating: 40
- mixed: 13
- unclear: 7
- cleanly neutral: 0

The underlying text review categorized 21 of these 60 reviews as negative and 19 as positive; 13 were mixed and 7 were unclear. None was judged cleanly neutral. Because the sample intentionally balances error directions and apps, these counts diagnose error types but do not estimate their prevalence across all three-star reviews.

## TF-IDF-only versus current feature set

| Model | Accuracy | Balanced accuracy | Macro F1 | Weighted F1 | Neutral F1 |
|---|---:|---:|---:|---:|---:|
| TF-IDF only | 0.8211 | 0.5859 | 0.5892 | 0.8202 | 0.1103 |
| TF-IDF + engineered features | 0.8208 | 0.5867 | 0.5899 | 0.8196 | 0.1146 |

Full-feature minus TF-IDF-only changes:

- accuracy: -0.0003
- balanced accuracy: +0.0008
- macro F1: +0.0007
- weighted F1: -0.0006
- neutral F1: +0.0043

The two models agree on 6,829 of 6,920 predictions (98.68%). Engineered features fix 34 TF-IDF-only errors but change 36 correct TF-IDF-only predictions to errors, for a net loss of two correct predictions. The engineered feature set therefore does not provide a material overall improvement in this controlled split. Its small neutral-class gain is not enough to resolve the label ambiguity.

## Two-app holdout transfer

YouTube and DoorDash were selected before fitting to provide different domains, volumes, and collection-activity profiles while retaining all three weak-label classes.

Primary strict design:

- held-out apps absent from training: 2
- remaining training apps: 8
- training rows before shared-text removal: 26,807
- training rows after shared-text removal: 20,749
- training rows removed because their exact text group appeared in held-out apps: 6,058
- held-out test rows: 7,794
- train/test exact text-group overlap: 0

| Evaluation | Accuracy | Balanced accuracy | Macro F1 | Weighted F1 | Neutral F1 |
|---|---:|---:|---:|---:|---:|
| Original grouped same-app split | 0.8208 | 0.5867 | 0.5899 | 0.8196 | 0.1146 |
| Strict two-app holdout | 0.7753 | 0.5570 | 0.5611 | 0.7725 | 0.1043 |

The strict holdout lowers accuracy by -0.0455 and macro F1 by -0.0287. YouTube macro F1 is 0.5300; DoorDash macro F1 is 0.6257. This confirms app-level transfer variation.

The disclosed app-only sensitivity run has macro F1 0.5598, close to the strict result. Shared generic text does not explain away the transfer gap in this test.

## Error-source judgment

### 1. Label design is the first priority

The largest actionable issue is the meaning of the target. In the focused three-star error sample, the text frequently expresses clear positive or negative sentiment, mixed sentiment, or insufficient information instead of a clean neutral class. The next label iteration should retain the source rating but rename the derived class as a rating group rather than treating three stars as verified neutral sentiment. A manually labeled validation set should keep text sentiment and rating consistency as separate fields.

### 2. Evaluation setup is the second priority

The two-app holdout produces a meaningful decline and different results by app. Future evaluation should retain:

- exact-text-group isolation;
- a same-distribution grouped split for continuity;
- one or more app-heldout tests;
- per-class and per-app metrics; and
- explicit reporting of neutral support and error composition.

### 3. Feature design is the third priority

The current engineered features produce only a negligible macro-F1 change relative to TF-IDF alone. They should not be treated as a demonstrated improvement. TF-IDF-only is the cleaner reference until label and evaluation design are improved. Later feature work should be tied to reviewed error types such as contrast language, negation, short ambiguous text, and non-English coverage.

## Recommended next step

Do not move to a more complex model yet. First create a manually labeled validation set that includes both correct and incorrect predictions and keeps three separate concepts:

1. source star rating;
2. text sentiment; and
3. rating-text consistency.

Then rerun the simple TF-IDF reference under both grouped same-distribution and app-heldout evaluation. Only after that should a new feature or model be accepted, and only if it improves the relevant class and transfer metrics consistently.

## Limitations

1. The 120-row review is a designed error sample rather than a random estimate of all reviews.
2. One reviewer performed the annotations and no independent adjudication was completed.
3. Manual interpretation is difficult for short, ambiguous, sarcastic, or non-English reviews.
4. Only two apps were held out in this transfer test.
5. Strict text-group isolation removes many generic repeated-text rows from training.
6. Results apply to the current 10-app snapshot and fixed model configuration.
7. Ratings remain weak labels and do not establish true sentiment.
