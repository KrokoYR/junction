use chrono::{DateTime, Utc};
use sqlx::PgPool;
use uuid::Uuid;

use crate::{error::AppError, models::session::SessionRecord};

pub async fn save_session(
    pool: &PgPool,
    session_key: String,
    expires_at: DateTime<Utc>,
) -> Result<SessionRecord, AppError> {
    // Insert new session into database
    let session = sqlx::query_as!(
        SessionRecord,
        r#"
        INSERT INTO sessions (session_key, expires_at)
        VALUES ($1, $2)
        RETURNING id, session_key, verification_id, created_at, expires_at, is_active, is_verified
        "#,
        session_key,
        expires_at,
    )
    .fetch_one(pool)
    .await?;

    Ok(session)
}

pub async fn update_session_verification(
    pool: &PgPool,
    session_key: String,
    verification_id: Uuid,
    is_verified: bool,
) -> Result<SessionRecord, AppError> {
    let session = sqlx::query_as!(
        SessionRecord,
        r#"
        UPDATE sessions
        SET is_verified = $3, verification_id = $2
        WHERE session_key = $1
        RETURNING id, session_key, verification_id, created_at, expires_at, is_active, is_verified
        "#,
        session_key,
        verification_id,
        is_verified
    )
    .fetch_one(pool)
    .await?;

    Ok(session)
}

pub async fn get_session_by_key(
    pool: &PgPool,
    session_key: String,
) -> Result<SessionRecord, AppError> {
    let session = sqlx::query_as!(
        SessionRecord,
        r#"
        SELECT id, session_key, verification_id, created_at, expires_at, is_active, is_verified
        FROM sessions
        WHERE session_key = $1
        "#,
        session_key
    )
    .fetch_one(pool)
    .await?;

    Ok(session)
}
