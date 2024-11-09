use sqlx::PgPool;
use uuid::Uuid;

use crate::{error::AppError, models::verification::VerificationRecord};

pub async fn save_verification(
    pool: &PgPool,
    public_token: String,
    is_verified: bool,
) -> Result<VerificationRecord, AppError> {
    let record = sqlx::query_as!(
        VerificationRecord,
        r#"
        INSERT INTO verifications (id, public_token, is_verified)
        VALUES ($1, $2, $3)
        RETURNING id, public_token, is_verified, created_at
        "#,
        Uuid::new_v4(),
        public_token,
        is_verified,
    )
    .fetch_one(pool)
    .await?;

    Ok(record)
}

pub async fn get_verification(pool: &PgPool, id: Uuid) -> Result<VerificationRecord, AppError> {
    sqlx::query_as!(
        VerificationRecord,
        r#"
        SELECT id, is_verified, public_token, created_at
        FROM verifications
        WHERE id = $1
        "#,
        id
    )
    .fetch_one(pool)
    .await
    .map_err(|e| AppError::Database(e))
}
