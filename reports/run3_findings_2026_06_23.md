
# Run 3 Findings

## Purpose

This notebook records Run 3 of the public app review source validation.

## Google Play Result

Google Play remained stable in Run 3.

The collection again returned 6,000 total reviews across YouTube, TikTok, and Spotify, with 2,000 newest US / English reviews per app. There were no failed app-level requests.

The duplicate check again showed stable review keys and no duplicate rows within the Google Play Run 3 collection.

This confirms that Google Play collection continues to be stable across repeated runs.

## iOS App Store Result

The iOS App Store public RSS feed was also technically accessible in Run 3.

The Run 3 iOS test repeated the same structure as the previous runs: three apps, five countries, and ten pages per app-country pair.

Most app-country pairs continued to return usable reviews. Similar to earlier runs, some iOS app-country combinations were less reliable, which confirms that iOS coverage depends more on country and page rotation.

The iOS results also continued to show more duplicate handling needs than Google Play.

## Exploratory and Data Quality Checks

Run 3 repeated the same exploratory and data quality checks as Run 1 and Run 2, including:

- rating distribution
- review length
- missing fields
- app version coverage
- language detection
- duplicate summary
- source-level comparison

The results stayed generally consistent with the earlier runs. Google Play had stronger within-run uniqueness and cleaner repeated collection behavior. iOS remained technically usable, but still had more coverage and duplicate-handling issues.

## Current Run 3 Conclusion

Run 3 further supports the same conclusion from Run 1 and Run 2.

Google Play remains the stronger primary source for a recurring app review ingestion pilot because it provides stable volume, stable review IDs, clean duplicate handling, and consistent metadata structure.

iOS App Store public RSS remains useful as a secondary source, but it should not be treated as the primary source because of country/page dependence, empty-page risk, and more duplicate rows.

The next step is to compare Run 3 with Run 2 to confirm repeated-run stability, new review capture, schema consistency, and freshness patterns.
