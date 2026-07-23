# Google Play Review Feature Engineering v0 Report

## Scope

This feature layer is generated from the validated Phase 2 SQLite database containing 34,601 cleaned Google Play reviews across 10 apps.

The version is intentionally lightweight. It does not train a sentiment model, topic model, issue classifier, or any other machine-learning model. It defines transparent features that can later support EDA and model design.

During normal operations, the sequence remains:

1. run the normal ingestion process
2. run the monitoring layer
3. stop downstream use if a hard failure is present
4. document warnings and continue only when the run remains usable
5. generate or refresh the feature layer

## Review-level features

The output includes app identity, score and rating group, cleaned-text length, short and low-signal flags, review and collection dates, first-collection age, deduplication checks, repeated-text status, language heuristic status, developer-reply availability, and seven simple issue indicators.

The complete definitions are stored in `outputs/feature_definitions_v0.csv` and `reports/feature_engineering_v0_feature_dictionary.md`.

## Overall results

- Review rows: 34,601
- Apps: 10
- Average rating: 3.725
- Low-rating reviews: 28.75%
- Short reviews: 45.01%
- Low-signal reviews under the v0 rule: 37.26%
- Repeated cleaned text within the same app: 23.01%
- Reviews with a developer reply: 12.81%
- Likely non-English reviews: 2.05% of all reviews
- Language undetermined: 40.35%, mainly because many reviews are too short for a reliable rule
- Reviews matching at least one issue indicator: 17.90%
- Duplicate review identities in the persisted feature snapshot: 0

## App-level aggregates

| app_name | review_volume | average_rating | low_rating_share | short_review_share | low_signal_share | developer_reply_share | any_issue_indicator_share |
|---|---|---|---|---|---|---|---|
| DoorDash | 1975 | 3.101 | 44.20% | 23.49% | 16.81% | 0.00% | 27.44% |
| Duolingo | 2098 | 4.5 | 7.63% | 39.66% | 30.46% | 0.00% | 5.67% |
| Google Maps | 2635 | 3.614 | 31.61% | 46.26% | 40.30% | 21.06% | 13.70% |
| Instagram | 6045 | 3.847 | 26.22% | 52.56% | 44.35% | 0.00% | 18.48% |
| Netflix | 2365 | 3.519 | 33.66% | 34.33% | 28.84% | 0.00% | 19.83% |
| Reddit | 1991 | 2.984 | 48.37% | 30.94% | 23.91% | 0.00% | 20.14% |
| Spotify | 4174 | 3.883 | 23.14% | 35.03% | 26.83% | 10.85% | 26.59% |
| TikTok | 4059 | 3.839 | 25.77% | 49.20% | 39.34% | 84.21% | 16.01% |
| Uber | 3440 | 3.839 | 27.01% | 48.28% | 42.82% | 0.23% | 13.17% |
| YouTube | 5819 | 3.66 | 30.88% | 57.28% | 48.62% | 0.00% | 16.72% |

The app-level values describe the collected database snapshot and should not be treated as general app quality rankings.

## Issue indicator rates

| feature_name | review_count | review_share |
|---|---|---|
| issue_login_account_flag | 1626 | 4.70% |
| issue_payment_billing_flag | 1511 | 4.37% |
| issue_ads_flag | 1185 | 3.42% |
| issue_update_version_flag | 1101 | 3.18% |
| issue_crash_bug_flag | 1022 | 2.95% |
| issue_performance_loading_flag | 588 | 1.70% |
| issue_support_service_flag | 583 | 1.68% |

The issue indicators are keyword screens only. A match does not prove that the issue occurred, and a non-match does not prove that it did not occur.

## Most useful features

The strongest first-version features are app identity, score/rating group, review and collection timestamps, review-length measures, and developer-reply availability. They are source-provided or deterministic and can directly support EDA and data-quality segmentation.

The duplicate identity flag is also reliable, but it has no variance in this persisted database because the ingestion process already removed duplicate review identities. It is most useful as a validation guard.

## Least reliable features

The non-English flag, low-signal flag, and keyword issue indicators are heuristic. The language rule deliberately leaves uncertain and short reviews as `undetermined`. The keyword rules do not understand context, negation, spelling variation, or issue wording in languages outside the current English keyword groups.

These fields are appropriate for initial filtering and descriptive EDA. They should not be presented as ground-truth sentiment, language, topic, or issue labels.

## Validation

All source-package, database, review-level, and app-level validation checks passed. The feature output preserved all 34,601 cleaned review rows, retained 10 apps, created no duplicate identities, and reconciled all derived counts and app-level volumes.
