# Google Play Phase 2 Cadence Test — Final Run A and Run B Report

## Controlled setup

- Source: Google Play
- Apps: 10
- Target: 1,200 newest reviews per app
- Language and country: English / United States
- Duplicate identity: `source + app_id + review_id`
- Final raw review rows: 34,601
- Final cleaned review rows: 34,601
- Completed Phase 2 runs: 6
- Final database size: 84.68 MB

## Run B first-collection baseline

The Run B first collection established the database baseline for the later follow-up collection.

It occurred 100.65 hours after Cadence Run A. Because this gap was much longer than the controlled higher-frequency intervals, the first collection is reported as a baseline and is not treated as a separate twice-daily outcome.

| Gap from Run A | Reviews fetched | New DB inserts | Duplicate rate | Posted after prior run boundary | Older reviews surfaced | New-insert timestamp range | Wall-clock runtime | DB row growth | DB growth |
|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|
| 100.65 h | 12,000 | 8,638 | 28.02% | 8,015 | 623 | 2026-07-08T21:16:36+00:00 to 2026-07-13T01:56:37+00:00 | 30.76 s | 8,638 | 18.56 MB |

The first collection returned 8,638 database-new records. Of those, 8,015 had review timestamps after the prior Run A completion boundary and 623 were older reviews that surfaced later.

## Controlled cadence run-level comparison

| Test | Interval | Reviews fetched | New DB inserts | Duplicate rate | Posted between collections | Older reviews surfaced | New-insert timestamp range | Median source lag | Wall-clock runtime | DB row growth | DB growth | Errors |
|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|
| Cadence Run A | 17.16 h | 12,000 | 4,395 | 63.38% | 0 | 4,395 | 2026-07-04T15:23:42+00:00 to 2026-07-08T21:14:19+00:00 | 24.04 h | 28.14 s | 4,395 | 11.76 MB | 0 |
| Cadence Run B | 14.66 h | 12,000 | 3,753 | 68.73% | 0 | 3,753 | 2026-07-13T01:56:51+00:00 to 2026-07-13T16:36:13+00:00 | 24.04 h | 30.02 s | 3,753 | 10.59 MB | 0 |

Database growth is reported at the run level. SQLite file-page growth cannot be assigned reliably to individual apps.

## Cadence Run A app-level results

Cadence Run A followed the Day 3 collection after an average interval of 17.16 hours.

| App | New DB inserts | Duplicate rate | App processing runtime | New-insert timestamp range | Posted between collections |
|---|---:|---:|---:|---|---:|
| YouTube | 1,199 | 0.08% | 1.22 s | 2026-07-08T10:17:11+00:00 to 2026-07-08T21:13:22+00:00 | 0 |
| TikTok | 622 | 48.17% | 0.68 s | 2026-07-08T04:08:06+00:00 to 2026-07-08T21:14:15+00:00 | 0 |
| Spotify | 580 | 51.67% | 0.74 s | 2026-07-08T04:06:13+00:00 to 2026-07-08T21:14:19+00:00 | 0 |
| Instagram | 1,198 | 0.17% | 1.02 s | 2026-07-08T11:26:23+00:00 to 2026-07-08T21:12:32+00:00 | 0 |
| Uber | 317 | 73.58% | 0.98 s | 2026-07-08T04:09:18+00:00 to 2026-07-08T21:12:10+00:00 | 0 |
| DoorDash | 73 | 93.92% | 0.57 s | 2026-07-08T04:54:25+00:00 to 2026-07-08T21:03:08+00:00 | 0 |
| Duolingo | 6 | 99.50% | 0.78 s | 2026-07-08T04:17:19+00:00 to 2026-07-08T15:57:17+00:00 | 0 |
| Google Maps | 184 | 84.67% | 0.65 s | 2026-07-04T15:23:42+00:00 to 2026-07-08T21:14:19+00:00 | 0 |
| Netflix | 123 | 89.75% | 0.72 s | 2026-07-08T04:08:00+00:00 to 2026-07-08T21:01:32+00:00 | 0 |
| Reddit | 93 | 92.25% | 0.68 s | 2026-07-08T04:15:59+00:00 to 2026-07-08T20:43:50+00:00 | 0 |

## Cadence Run B follow-up app-level results

Cadence Run B followed the Run B first collection after an average interval of 14.66 hours.

| App | New DB inserts | Duplicate rate | App processing runtime | New-insert timestamp range | Posted between collections |
|---|---:|---:|---:|---|---:|
| YouTube | 994 | 17.17% | 1.93 s | 2026-07-13T01:59:02+00:00 to 2026-07-13T16:35:07+00:00 | 0 |
| TikTok | 406 | 66.17% | 0.79 s | 2026-07-13T01:59:51+00:00 to 2026-07-13T16:34:23+00:00 | 0 |
| Spotify | 456 | 62.00% | 0.77 s | 2026-07-13T01:56:51+00:00 to 2026-07-13T16:35:05+00:00 | 0 |
| Instagram | 1,196 | 0.33% | 0.85 s | 2026-07-13T08:02:32+00:00 to 2026-07-13T16:36:13+00:00 | 0 |
| Uber | 309 | 74.25% | 0.78 s | 2026-07-13T02:01:50+00:00 to 2026-07-13T16:34:04+00:00 | 0 |
| DoorDash | 25 | 97.92% | 0.93 s | 2026-07-13T01:58:41+00:00 to 2026-07-13T16:32:29+00:00 | 0 |
| Duolingo | 3 | 99.75% | 0.97 s | 2026-07-13T08:45:54+00:00 to 2026-07-13T16:07:35+00:00 | 0 |
| Google Maps | 151 | 87.42% | 0.84 s | 2026-07-13T02:06:35+00:00 to 2026-07-13T16:34:26+00:00 | 0 |
| Netflix | 152 | 87.33% | 0.86 s | 2026-07-13T01:58:20+00:00 to 2026-07-13T16:31:09+00:00 | 0 |
| Reddit | 61 | 94.92% | 0.74 s | 2026-07-13T02:03:14+00:00 to 2026-07-13T16:32:15+00:00 | 0 |

## Timestamp and source-freshness finding

Cadence Run A inserted 4,395 database-new records and Cadence Run B inserted 3,753, for a combined total of 8,148.

Timestamp validation found zero reviews posted between collections in both controlled cadence tests.

All 8,148 database-new records had review timestamps at or before the preceding app-specific collection boundary. They were new to the database because they entered the returned review window later, not because they were newly posted between collections.

The median difference between collection time and the newest returned review timestamp was 24.04 hours in Cadence Run A and 24.04 hours in Cadence Run B.

This approximately 24-hour returned-window lag was consistent in the two controlled tests, but it should not be interpreted as a universal Google Play rule.

## App-level cadence recommendation

The operational rules used in this experiment were:

- Twice-daily coverage candidate: at least 80% new-to-database returned-window turnover in both cadence tests
- Once-daily candidate: at least 70% duplicate in both cadence tests
- Monitor: results between those two patterns

These are project-specific decision rules for the tested 1,200-review window.

| App | Run A new insert rate | Run B new insert rate | Timestamp freshness benefit | Recommendation | Reason |
|---|---:|---:|---|---|---|
| YouTube | 99.92% | 82.83% | Not demonstrated | Twice-daily candidate for returned-window coverage | High returned-window turnover in both tests. The fixed 1,200-review batch was close to saturation, creating a coverage risk under a longer interval. No posting-time freshness benefit was observed. |
| TikTok | 51.83% | 33.83% | Not demonstrated | Monitor before changing cadence | Moderate returned-window turnover, but no timestamp-verified freshness benefit. More evidence is needed before creating an app-specific twice-daily exception. |
| Spotify | 48.33% | 38.00% | Not demonstrated | Monitor before changing cadence | Moderate returned-window turnover, but no timestamp-verified freshness benefit. More evidence is needed before creating an app-specific twice-daily exception. |
| Instagram | 99.83% | 99.67% | Not demonstrated | Twice-daily candidate for returned-window coverage | High returned-window turnover in both tests. The fixed 1,200-review batch was close to saturation, creating a coverage risk under a longer interval. No posting-time freshness benefit was observed. |
| Uber | 26.42% | 25.75% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |
| DoorDash | 6.08% | 2.08% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |
| Duolingo | 0.50% | 0.25% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |
| Google Maps | 15.33% | 12.58% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |
| Netflix | 10.25% | 12.67% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |
| Reddit | 7.75% | 5.08% | Not demonstrated | Once-daily candidate | Duplicate-heavy in both tests, with no timestamp-verified reviews posted between collections. |

## Final recommendation

A blanket twice-daily schedule is not supported for all 10 apps.

- **Twice-daily coverage candidates:** YouTube, Instagram
- **Once-daily candidates:** Uber, DoorDash, Duolingo, Google Maps, Netflix, Reddit
- **Monitor before changing cadence:** TikTok, Spotify

YouTube and Instagram are twice-daily candidates only for returned-window coverage. Their fixed 1,200-review windows showed high turnover in both controlled cadence tests, so a longer interval may create a coverage risk.

No posting-time freshness benefit was demonstrated for YouTube, Instagram, or any other tested app.

Uber, DoorDash, Duolingo, Google Maps, Netflix, and Reddit were duplicate-heavy in both cadence tests and can remain on once-daily collection under the current setup.

TikTok and Spotify showed moderate returned-window turnover and should remain under observation before an app-specific cadence exception is introduced.

## Measurement notes

- Run-level runtime is wall-clock collection time, including the fixed delay between app requests.
- App-level runtime is the processing time recorded for each app request.
- New database inserts indicate review identities not previously stored in the database.
- New database inserts are not automatically treated as newly posted reviews.
- Review-posting freshness is determined from app-specific review and collection timestamps.
- Database size growth is reported only at run level.
- The conclusions apply to the tested 10 apps, 1,200-review returned window, and recorded controlled runs.
