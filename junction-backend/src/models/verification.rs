use serde::{Deserialize, Serialize};
use sqlx::types::chrono::{DateTime as PgDateTime, Utc as PgUtc};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Deserialize, Validate)]
pub struct VerificationRequest {
    #[validate(length(min = 1))]
    pub video: String,
    #[validate(length(min = 1))]
    pub id_card: String,
    #[validate(length(min = 1))]
    pub public_token: String,
}

#[derive(Debug, Serialize)]
pub struct VerificationResponse {
    pub is_verified: bool,
    pub verification_id: Uuid,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct VerificationRecord {
    pub id: Uuid,
    pub is_verified: bool,
    pub public_token: String,
    pub created_at: Option<PgDateTime<PgUtc>>,
}
