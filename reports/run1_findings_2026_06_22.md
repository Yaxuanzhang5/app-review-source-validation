
# Run 1 Findings

## Purpose

This clean Run 1 validation tested Google Play and iOS App Store public review sources for recurring review ingestion.

The validation focused on:

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

## Google Play Result

Google Play performed strongly in Run 1.

The collection returned 6,000 total reviews across three apps: YouTube, TikTok, and Spotify. Each app returned 2,000 newest US / English reviews. All three app requests completed successfully, with no failed app-level requests.

Google Play also provided stable review IDs. The duplicate check showed 6,000 total reviews, 6,000 unique review keys, and 0 duplicate rows. This is important because stable review IDs make future repeated collection and duplicate handling much easier.

The metadata coverage was also usable. Core fields such as review ID, user name, review text, rating, thumbs-up count, and review date were complete. App version fields were partially missing, and developer reply fields were missing for many reviews, but this is expected because not every review has an app version or developer response.

Based on Run 1, Google Play is the stronger primary source for repeated collection testing.

## iOS App Store Result

The iOS App Store public RSS feed was also technically accessible.

The Run 1 iOS test requested reviews for three apps across five countries and ten pages per app-country pair. The test collected 7,000 total reviews. Most app-country pairs returned usable results, but TikTok India returned 0 reviews with 10 empty pages.

This shows that iOS country and page rotation can increase review coverage, but the coverage is still less consistent than Google Play. Some app-country pairs may return empty results even when the request itself does not fail.

The iOS duplicate check showed 7,000 total reviews, 6,899 unique review keys, and 101 duplicate rows. The duplicate rate was about 1.44%. This is manageable, but it confirms that duplicate handling is necessary for iOS.

## Source Comparison

Google Play and iOS both passed the basic technical access test, but they have different strengths.

Google Play is cleaner for recurring ingestion because it returned stable review IDs, no duplicate rows in Run 1, strong volume, and consistent metadata.

iOS returned even more total reviews in this run, but it required country/page rotation and still had empty coverage for one app-country pair. iOS also had some duplicate rows, so it is better treated as a secondary source for now.

## Exploratory and Data Quality Findings

I also started exploratory and data quality analysis on the collected data.

The rating distribution shows that both sources contain a mix of positive and negative reviews, with many 1-star and 5-star reviews. This is useful for downstream sentiment or quality analysis.

The review length summary shows that iOS reviews are generally longer than Google Play reviews in this run.

The missing field summary shows that Google Play core fields were complete, but app version and developer reply fields had missing values. iOS fields checked in this run were complete for the collected reviews.

The app version coverage check shows that iOS had full app version coverage in this run, while Google Play app version coverage varied by app.

The language detection result suggests that most reviews are English, but some reviews were detected as other languages. Since language detection can be noisy for short reviews, this should be treated as a rough data quality flag rather than a perfect language label.

## Current Conclusion

Run 1 confirms that Google Play is feasible as the primary source for a recurring app review ingestion pilot.

iOS App Store public RSS feed is also feasible as a secondary source, but it has more coverage and duplicate-handling issues.

The next step is to run the same notebook again as Run 2 and compare Run 2 against Run 1. The Run 2 comparison should focus on new review counts, overlap with Run 1, duplicate rates across runs, field consistency, request failures, and freshness patterns.
