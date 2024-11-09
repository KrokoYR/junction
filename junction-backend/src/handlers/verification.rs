use axum::{extract::State, Json};
use validator::Validate;

use crate::{
    db,
    error::AppError,
    models::verification::{VerificationRequest, VerificationResponse},
    AppState,
};

pub async fn verify_user(
    State(state): State<AppState>,
    Json(payload): Json<VerificationRequest>,
) -> Result<Json<VerificationResponse>, AppError> {
    payload
        .validate()
        .map_err(|e| AppError::Validation(e.to_string()))?;

    // TODO: this place suppose to call the AI service to verify the person on the video
    // and compare it with the person on the ID Card
    let is_verified = payload.video == payload.id_card;
    // Imitate the response time(~200ms)
    tokio::time::sleep(tokio::time::Duration::from_millis(200)).await;

    // Return error if not verified
    if !is_verified {
        return Err(AppError::Validation(
            "Verification failed. Person on video is not the same as on ID Card".to_string(),
        ));
    }

    let val =
        db::verification::save_verification(&state.pool, payload.public_token, is_verified).await?;

    Ok(Json(VerificationResponse {
        is_verified: val.is_verified,
        verification_id: val.id,
    }))
}
