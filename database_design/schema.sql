-- Google Play Review Pipeline - SQL Schema
-- PostgreSQL-style database design for recurring Google Play review ingestion

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- 1. App / Source Metadata
-- =========================================================

CREATE TABLE app_sources (
    app_source_id BIGSERIAL PRIMARY KEY,

    platform TEXT NOT NULL CHECK (platform IN ('google_play')),
    source_app_id TEXT NOT NULL,              -- Google Play package name, e.g. com.spotify.music
    app_name TEXT,
    developer_name TEXT,

    country_code CHAR(2) NOT NULL DEFAULT 'us',
    language_code CHAR(2) NOT NULL DEFAULT 'en',
    source_url TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_app_source UNIQUE (
        platform,
        source_app_id,
        country_code,
        language_code
    )
);

-- =========================================================
-- 2. Ingestion Runs
-- One row per full ingestion job.
-- =========================================================

CREATE TABLE ingestion_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    run_label TEXT NOT NULL,
    pipeline_name TEXT NOT NULL DEFAULT 'google_play_review_ingestion',

    source_tool TEXT NOT NULL DEFAULT 'google-play-scraper',
    source_tool_version TEXT,
    code_version TEXT,

    started_at TIMESTAMPTZ NOT NULL,
    finished_at TIMESTAMPTZ,

    status TEXT NOT NULL CHECK (
        status IN ('started', 'success', 'partial_success', 'failed')
    ),

    total_fetched_count INTEGER NOT NULL DEFAULT 0 CHECK (total_fetched_count >= 0),
    total_inserted_count INTEGER NOT NULL DEFAULT 0 CHECK (total_inserted_count >= 0),
    total_already_known_count INTEGER NOT NULL DEFAULT 0 CHECK (total_already_known_count >= 0),
    total_updated_count INTEGER NOT NULL DEFAULT 0 CHECK (total_updated_count >= 0),

    error_message TEXT,
    run_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 3. Ingestion Run Targets
-- One row per app/source collected within a run.
-- =========================================================

CREATE TABLE ingestion_run_targets (
    run_target_id BIGSERIAL PRIMARY KEY,

    run_id UUID NOT NULL REFERENCES ingestion_runs(run_id) ON DELETE CASCADE,
    app_source_id BIGINT NOT NULL REFERENCES app_sources(app_source_id),

    sort_method TEXT NOT NULL DEFAULT 'newest',
    target_count INTEGER CHECK (target_count > 0),
    page_size INTEGER NOT NULL DEFAULT 200 CHECK (page_size BETWEEN 1 AND 200),
    filter_score_with SMALLINT CHECK (filter_score_with BETWEEN 1 AND 5),

    continuation_token_start TEXT,
    continuation_token_end TEXT,

    started_at TIMESTAMPTZ NOT NULL,
    finished_at TIMESTAMPTZ,

    status TEXT NOT NULL CHECK (
        status IN ('started', 'success', 'partial_success', 'failed')
    ),

    fetched_count INTEGER NOT NULL DEFAULT 0 CHECK (fetched_count >= 0),
    inserted_count INTEGER NOT NULL DEFAULT 0 CHECK (inserted_count >= 0),
    already_known_count INTEGER NOT NULL DEFAULT 0 CHECK (already_known_count >= 0),
    updated_count INTEGER NOT NULL DEFAULT 0 CHECK (updated_count >= 0),
    duplicate_in_run_count INTEGER NOT NULL DEFAULT 0 CHECK (duplicate_in_run_count >= 0),

    earliest_review_created_at TIMESTAMPTZ,
    latest_review_created_at TIMESTAMPTZ,

    error_message TEXT,

    CONSTRAINT uq_run_target UNIQUE (run_id, app_source_id)
);

-- =========================================================
-- 4. Canonical Review Records
-- One row per unique source review per app/source.
-- =========================================================

CREATE TABLE reviews (
    review_pk BIGSERIAL PRIMARY KEY,

    app_source_id BIGINT NOT NULL REFERENCES app_sources(app_source_id),
    source_review_id TEXT NOT NULL,           -- Google Play reviewId

    source_user_name TEXT,

    score SMALLINT CHECK (score BETWEEN 1 AND 5),
    thumbs_up_count INTEGER CHECK (thumbs_up_count >= 0),

    raw_content TEXT,
    cleaned_content TEXT,
    content_hash CHAR(64),                    -- SHA-256 hash of normalized cleaned text

    review_created_at TIMESTAMPTZ,            -- Google Play field: at
    review_created_version TEXT,              -- Google Play field: reviewCreatedVersion
    app_version TEXT,                         -- Google Play field: appVersion

    reply_content TEXT,
    replied_at TIMESTAMPTZ,

    first_seen_run_id UUID REFERENCES ingestion_runs(run_id) ON DELETE SET NULL,
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    last_seen_run_id UUID REFERENCES ingestion_runs(run_id) ON DELETE SET NULL,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_review_source_id UNIQUE (
        app_source_id,
        source_review_id
    )
);

-- =========================================================
-- 5. Review Observations
-- Tracks whether each review appeared in a specific ingestion run.
-- =========================================================

CREATE TABLE review_observations (
    observation_id BIGSERIAL PRIMARY KEY,

    run_target_id BIGINT NOT NULL REFERENCES ingestion_run_targets(run_target_id) ON DELETE CASCADE,
    review_pk BIGINT NOT NULL REFERENCES reviews(review_pk) ON DELETE CASCADE,

    source_review_id TEXT NOT NULL,

    fetched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    row_number_in_fetch INTEGER CHECK (row_number_in_fetch >= 0),

    insert_status TEXT NOT NULL CHECK (
        insert_status IN ('inserted', 'already_known', 'updated')
    ),

    occurrence_count_in_run INTEGER NOT NULL DEFAULT 1 CHECK (occurrence_count_in_run >= 1),

    raw_payload JSONB NOT NULL,

    CONSTRAINT uq_review_observation UNIQUE (
        run_target_id,
        source_review_id
    )
);

-- =========================================================
-- 6. Review Quality Flags
-- One row per canonical review.
-- =========================================================

CREATE TABLE review_quality_flags (
    review_pk BIGINT PRIMARY KEY REFERENCES reviews(review_pk) ON DELETE CASCADE,

    raw_text_length INTEGER CHECK (raw_text_length >= 0),
    cleaned_text_length INTEGER CHECK (cleaned_text_length >= 0),

    normalized_content_hash CHAR(64),

    is_empty_after_cleaning BOOLEAN NOT NULL DEFAULT FALSE,
    is_short_text BOOLEAN NOT NULL DEFAULT FALSE,
    is_low_signal BOOLEAN NOT NULL DEFAULT FALSE,
    low_signal_reason TEXT,

    is_repeated_generic_content BOOLEAN NOT NULL DEFAULT FALSE,
    repeated_content_count_app INTEGER NOT NULL DEFAULT 0 CHECK (repeated_content_count_app >= 0),
    repeated_content_count_global INTEGER NOT NULL DEFAULT 0 CHECK (repeated_content_count_global >= 0),

    is_missing_review_created_version BOOLEAN NOT NULL DEFAULT FALSE,
    is_missing_app_version BOOLEAN NOT NULL DEFAULT FALSE,

    has_developer_reply BOOLEAN NOT NULL DEFAULT FALSE,

    quality_flag_version TEXT NOT NULL DEFAULT 'v1',
    computed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 7. Recommended Indexes
-- =========================================================

CREATE INDEX idx_app_sources_active
    ON app_sources(is_active);

CREATE INDEX idx_reviews_app_created_at
    ON reviews(app_source_id, review_created_at DESC);

CREATE INDEX idx_reviews_score
    ON reviews(score);

CREATE INDEX idx_reviews_content_hash
    ON reviews(content_hash);

CREATE INDEX idx_reviews_first_seen_at
    ON reviews(first_seen_at);

CREATE INDEX idx_reviews_last_seen_at
    ON reviews(last_seen_at);

CREATE INDEX idx_run_targets_run_id
    ON ingestion_run_targets(run_id);

CREATE INDEX idx_observations_run_target
    ON review_observations(run_target_id);

CREATE INDEX idx_observations_insert_status
    ON review_observations(insert_status);

CREATE INDEX idx_quality_low_signal
    ON review_quality_flags(is_low_signal);

CREATE INDEX idx_quality_repeated_content
    ON review_quality_flags(is_repeated_generic_content);

CREATE INDEX idx_quality_missing_app_version
    ON review_quality_flags(is_missing_app_version);

-- =========================================================
-- 8. Analysis-Ready View
-- =========================================================

CREATE OR REPLACE VIEW vw_google_play_reviews_analysis AS
SELECT
    a.platform,
    a.source_app_id,
    a.app_name,
    a.developer_name,
    a.country_code,
    a.language_code,

    r.review_pk,
    r.source_review_id,
    r.score,
    r.thumbs_up_count,

    r.raw_content,
    r.cleaned_content,

    r.review_created_at,
    r.review_created_version,
    r.app_version,

    r.reply_content,
    r.replied_at,

    r.first_seen_at,
    r.last_seen_at,

    q.raw_text_length,
    q.cleaned_text_length,
    q.is_empty_after_cleaning,
    q.is_short_text,
    q.is_low_signal,
    q.low_signal_reason,
    q.is_repeated_generic_content,
    q.repeated_content_count_app,
    q.repeated_content_count_global,
    q.is_missing_review_created_version,
    q.is_missing_app_version,
    q.has_developer_reply,
    q.quality_flag_version,
    q.computed_at AS quality_flags_computed_at

FROM reviews r
JOIN app_sources a
    ON r.app_source_id = a.app_source_id
LEFT JOIN review_quality_flags q
    ON r.review_pk = q.review_pk;
