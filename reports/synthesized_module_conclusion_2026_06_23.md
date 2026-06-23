
# Synthesized Summary and Final Module Conclusion

## Purpose

This report wraps up the current source validation module after three completed runs.

The goal of this module was to validate whether public app review sources can support a recurring review ingestion workflow. The validation focused on access method, review volume, metadata fields, pagination and batching, duplicate handling, freshness, schema consistency, request stability, and basic exploratory/data quality checks.

## Overall Google Play Result

Google Play was the strongest and most stable source across all three runs.

Across Run 1, Run 2, and Run 3, Google Play consistently returned:

- 6,000 reviews per run
- 2,000 reviews per app
- 3 tested apps: YouTube, TikTok, and Spotify
- 0 duplicate rows within each run
- stable review IDs
- consistent schema across repeated comparisons
- fresh reviews captured in repeated runs

The repeated-run comparisons showed that Google Play can capture new reviews while still keeping enough overlap with the previous run for duplicate handling.

In the Run 1 vs Run 2 comparison:

- YouTube captured 1,238 new reviews in Run 2, with 762 overlapping reviews.
- TikTok captured 620 new reviews in Run 2, with 1,380 overlapping reviews.
- Spotify captured 695 new reviews in Run 2, with 1,305 overlapping reviews.

In the Run 2 vs Run 3 comparison:

- YouTube captured 1,402 new reviews in Run 3, with 598 overlapping reviews.
- TikTok captured 596 new reviews in Run 3, with 1,404 overlapping reviews.
- Spotify captured 694 new reviews in Run 3, with 1,306 overlapping reviews.

All Google Play repeated-run comparisons showed the same schema across runs.

This confirms that Google Play is technically feasible for a small recurring review ingestion pilot. It can repeatedly return a stable review volume, preserve stable review IDs, support duplicate handling, and capture new reviews over time.

## Overall iOS App Store Result

The iOS App Store public RSS feed was also technically accessible and repeatable, but it was less consistent than Google Play.

Across the three runs, iOS returned useful review volume, but the exact results varied more:

- Run 1 collected 7,000 iOS reviews.
- Run 2 collected 7,000 iOS reviews.
- Run 3 collected 6,800 iOS reviews.

The duplicate counts also varied across runs. This confirms that duplicate handling is necessary for iOS.

The iOS repeated-run comparisons showed that iOS can capture new reviews across app-country pairs. However, iOS depends more heavily on country and page combinations. Some app-country pairs had high overlap across runs, while others captured more new reviews. Some combinations also returned fewer reviews in Run 3, which shows that iOS coverage is less consistent than Google Play.

Compared with Google Play, iOS has stronger limitations around:

- country/page coverage
- empty or incomplete app-country pairs
- duplicate rows
- less consistent collected volume

Based on these results, iOS should remain a secondary source rather than the primary ingestion path.

## Exploratory and Data Quality Findings

The exploratory and data quality checks were consistent with the source-level findings.

The analysis included:

- rating distribution
- review length
- missing fields
- app version coverage
- language detection
- duplicate summaries
- source-level comparison

Main findings:

- Both sources contain a mix of positive and negative reviews.
- Many reviews are either 1-star or 5-star.
- iOS reviews were generally longer than Google Play reviews.
- Google Play core fields were complete.
- Google Play app version and developer reply fields had missing values, which is expected.
- iOS checked fields were mostly complete for collected reviews.
- Language detection showed mostly English reviews, but some reviews were detected as other languages.
- Language detection should be treated as a rough data quality flag because short reviews can be misclassified.

## Final Recommendation

After three runs, Google Play should be treated as the primary source for the recurring app review ingestion pilot.

Google Play is recommended as the primary path because it provides:

- stable repeated collection
- strong and consistent review volume
- stable review IDs
- clean within-run duplicate handling
- schema consistency across runs
- clear new review capture across repeated runs
- usable metadata for downstream analysis

iOS App Store public RSS should remain a secondary source.

iOS is useful for additional coverage, especially across countries, but it should not be the main source because it has more duplicate rows, stronger country/page dependence, and less consistent collection volume.

## Final Module Conclusion

The current module validates that public app review collection is feasible.

The strongest path is to use Google Play as the main recurring ingestion source and keep iOS as a supplementary source. If this work moves into the next stage, the recommended next step is to convert the notebook workflow into reusable scripts and schedule additional recurring runs to continue monitoring freshness, failures, schema stability, and duplicate behavior over time.
