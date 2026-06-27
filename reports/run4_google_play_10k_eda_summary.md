# Run 4: Google Play 10k+ Review EDA and Data Quality Check

This run is the next step after the earlier Google Play / iOS validation runs. The earlier runs focused on source feasibility, recurring collection, schema consistency, stable identifiers, and duplicate tracking.

For this run, I focused on the actual content and quality of the Google Play review data before moving into SQL or database design.

## Goal

The goal of this run is to check whether Google Play review data is clean and useful enough to support recurring review ingestion, downstream analysis, basic text analysis, future modeling, and SQL/database design.

## Data Collection

I collected reviews from 10 mainstream Google Play apps:

* YouTube
* TikTok
* Instagram
* Spotify
* Uber
* DoorDash
* Duolingo
* Netflix
* Airbnb
* Walmart

For each app, I targeted 1,200 reviews.

Final sample:

* 12,000 total reviews
* 10 apps
* 1,200 reviews per app
* 12,000 unique review IDs
* review date range: 2026-05-28 17:50:21 to 2026-06-25 20:57:50

## Main Checks

This notebook checks rating distribution, review length, missing fields, duplicate review IDs, duplicate review content, near-duplicate review text, low-signal reviews, language patterns, timestamp coverage, app version coverage, and other basic data quality flags.

## Key Findings

The core fields are complete and usable. There are no missing values in review ID, review content, rating score, timestamp, or thumbs-up count. All 12,000 review IDs are unique.

The rating distribution has meaningful variation. Five-star reviews are the largest group, with 7,177 reviews, or 59.81% of the dataset. One-star reviews are also meaningful, with 2,859 reviews, or 23.82% of the dataset.

Missingness is mostly in optional or secondary fields. Developer reply content and reply timestamp are each missing in 81.51% of reviews, which is expected because many reviews do not receive developer replies. App version fields are each missing in 17.66% of records, so version-level analysis is possible but not fully complete.

There are no duplicate review IDs, which supports stable identifier tracking. However, repeated review content is common. There are 1,941 rows with exact duplicate content within the same app and 2,464 rows with exact duplicate content globally. These are mostly generic short reviews, so I treat them as content quality issues rather than collection errors.

The near-duplicate check found 16 near-duplicate pairs using TF-IDF and cosine similarity. This is small compared with the full dataset, but it is still useful to keep near-duplicate tracking as a future quality check.

Low-signal reviews are common. In total, 4,741 reviews, or about 39.51% of the dataset, were flagged as low-signal. These reviews can still be useful for rating-level analysis, but they should be flagged or filtered for text modeling.

The language check shows that US / English collection settings do not guarantee fully English review text. About 57.48% of reviews were detected as English, and 33.68% were too short for reliable language detection.

Timestamps are complete and usable. This supports recurring ingestion because future runs can compare records by review ID and timestamp.

## Conclusion

Overall, this deeper EDA supports the earlier conclusion that Google Play is the stronger primary source for the first recurring review ingestion pilot.

The data is structurally clean enough for downstream analysis and later database design. The main quality issues are manageable: low-signal content, repeated generic text, incomplete app version coverage, and mixed or too-short language signals.

The next step should be to design the SQL/database schema around these observed fields and include data quality flags for missing version fields, low-signal reviews, duplicate content, detected language, timestamps, and optional developer reply fields.

## Data Sharing Note

The raw internal review file is not included here because it may contain user-level fields such as usernames and user image links.

The shareable cleaned file removes direct user-level fields and uses hashed review IDs.
