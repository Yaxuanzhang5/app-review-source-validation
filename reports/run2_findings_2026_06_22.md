
# Run 2 Findings

## Purpose

This notebook records Run 2 of the public app review source validation.

## Google Play Result

Google Play remained stable in Run 2.

The collection again returned 6,000 total reviews across YouTube, TikTok, and Spotify, with 2,000 newest US / English reviews per app. There were no failed app-level requests. The duplicate check again showed 6,000 total reviews, 6,000 unique review keys, and 0 duplicate rows.

This confirms that Google Play collection is stable across repeated runs.

## iOS App Store Result

The iOS App Store public RSS feed was also stable in Run 2.

The Run 2 iOS test again collected 7,000 total reviews across three apps and five countries. Similar to Run 1, TikTok India returned 0 reviews, while the other app-country pairs returned usable results.

The iOS duplicate check showed 7,000 total reviews, 6,891 unique review keys, and 109 duplicate rows. This confirms that iOS duplicate handling is necessary.

## Run 1 vs Run 2 Comparison

The repeated-run comparison provides useful evidence for recurring ingestion feasibility.

For Google Play:

- YouTube had 1,238 new reviews in Run 2 and 762 overlapping reviews with Run 1.
- TikTok had 612 new reviews in Run 2 and 1,388 overlapping reviews with Run 1.
- Spotify had 695 new reviews in Run 2 and 1,305 overlapping reviews with Run 1.

All three Google Play app comparisons showed the same schema across runs.

For iOS, Run 2 also captured both overlapping and new reviews at the app-country level. Most app-country pairs had the same schema across runs. Some combinations had high overlap, while several US pairs had more new reviews, such as YouTube US, TikTok US, and Spotify US.

TikTok India remained unavailable in this run, which confirms that some iOS app-country pairs can return empty results even when the request itself does not fail.

## Current Conclusion

After two runs, Google Play remains the strongest candidate source for a recurring app review ingestion pilot.

It provides:

- stable repeated collection
- strong review volume
- stable review IDs
- clean duplicate handling
- cross-run schema consistency
- evidence of new review capture across runs

iOS App Store public RSS remains technically usable, but it is still better treated as a secondary source because of duplicate rows, country/page dependence, and less consistent coverage.

The next step is to upload Run 2 outputs to GitHub and share the repeated-run findings with John.
