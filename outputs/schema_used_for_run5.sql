
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS app_sources (
    app_source_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_platform TEXT NOT NULL,
    app_id TEXT NOT NULL,
    app_name TEXT NOT NULL,
    country TEXT NOT NULL,
    language TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE(source_platform, app_id, country, language)
);

CREATE TABLE IF NOT EXISTS ingestion_runs (
    run_id TEXT PRIMARY KEY,
    source_platform TEXT NOT NULL,
    run_started_at TEXT NOT NULL,
    run_finished_at TEXT,
    run_status TEXT NOT NULL,
    run_type TEXT NOT NULL,
    scraper_package TEXT,
    sort_order TEXT,
    requested_count_per_app INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ingestion_run_targets (
    run_target_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT NOT NULL,
    app_source_id INTEGER NOT NULL,
    requested_count INTEGER,
    fetched_count INTEGER,
    inserted_new_count INTEGER,
    duplicate_existing_count INTEGER,
    failed_count INTEGER,
    min_review_created_at TEXT,
    max_review_created_at TEXT,
    error_message TEXT,
    created_at TEXT NOT NULL,
    FOREIGN KEY(run_id) REFERENCES ingestion_runs(run_id),
    FOREIGN KEY(app_source_id) REFERENCES app_sources(app_source_id)
);

CREATE TABLE IF NOT EXISTS reviews (
    review_key TEXT PRIMARY KEY,
    app_source_id INTEGER NOT NULL,
    source_review_id TEXT NOT NULL,
    user_name TEXT,
    rating INTEGER,
    thumbs_up_count INTEGER,
    review_created_at TEXT,
    app_version TEXT,
    developer_reply_content TEXT,
    developer_replied_at TEXT,
    raw_response_json TEXT,
    first_seen_run_id TEXT NOT NULL,
    last_seen_run_id TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY(app_source_id) REFERENCES app_sources(app_source_id),
    FOREIGN KEY(first_seen_run_id) REFERENCES ingestion_runs(run_id),
    FOREIGN KEY(last_seen_run_id) REFERENCES ingestion_runs(run_id),
    UNIQUE(app_source_id, source_review_id)
);

CREATE TABLE IF NOT EXISTS review_texts (
    review_key TEXT PRIMARY KEY,
    raw_text TEXT,
    cleaned_text TEXT,
    raw_text_hash TEXT,
    cleaned_text_hash TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY(review_key) REFERENCES reviews(review_key)
);

CREATE TABLE IF NOT EXISTS review_quality_flags (
    quality_flag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT NOT NULL,
    review_key TEXT NOT NULL,
    is_missing_review_id INTEGER NOT NULL,
    is_missing_text INTEGER NOT NULL,
    is_short_text INTEGER NOT NULL,
    is_missing_rating INTEGER NOT NULL,
    is_missing_review_date INTEGER NOT NULL,
    is_repeated_content_in_batch INTEGER NOT NULL,
    content_length INTEGER,
    created_at TEXT NOT NULL,
    FOREIGN KEY(run_id) REFERENCES ingestion_runs(run_id),
    FOREIGN KEY(review_key) REFERENCES reviews(review_key),
    UNIQUE(run_id, review_key)
);
