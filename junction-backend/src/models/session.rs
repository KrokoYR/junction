use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::types::chrono::{DateTime as PgDateTime, Utc as PgUtc};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct CreateSessionRequest {}

#[derive(Serialize)]
pub struct CreateSessionResponse {
    pub session_key: String,
    pub expires_at: DateTime<Utc>,
}

#[derive(sqlx::FromRow, Debug)]
pub struct SessionRecord {
    pub id: Uuid,
    pub session_key: String,
    pub verification_id: Option<Uuid>,
    pub created_at: Option<PgDateTime<PgUtc>>,
    pub expires_at: Option<PgDateTime<PgUtc>>,
    pub is_active: Option<bool>,
    pub is_verified: Option<bool>,
}
