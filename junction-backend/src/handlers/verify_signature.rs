use axum::{extract::State, Json};
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use ed25519_dalek::{PublicKey, Signature, Verifier};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::db::{session::update_session_verification, verification::get_verification};
use crate::error::AppError;
use crate::AppState;

#[derive(Deserialize)]
pub struct VerifySignatureRequest {
    verification_id: Uuid,
    session_key: String,
    signature: String,
}

#[derive(Serialize)]
pub struct VerifySignatureResponse {
    is_valid: bool,
}

pub async fn verify_signature(
    State(state): State<AppState>,
    Json(payload): Json<VerifySignatureRequest>,
) -> Result<Json<VerifySignatureResponse>, AppError> {
    // Get verification record from database
    let verification = get_verification(&state.pool, payload.verification_id).await?;

    // Decode public token from base64
    let public_key_bytes = BASE64
        .decode(verification.public_token)
        .map_err(|_| AppError::InvalidSignature("Invalid public key format".into()))?;

    let public_key = PublicKey::from_bytes(&public_key_bytes)
        .map_err(|_| AppError::InvalidSignature("Invalid public key".into()))?;

    // Decode signature from base64
    let signature_bytes = BASE64
        .decode(payload.signature)
        .map_err(|_| AppError::InvalidSignature("Invalid signature format".into()))?;

    let signature = Signature::from_bytes(&signature_bytes)
        .map_err(|_| AppError::InvalidSignature("Invalid signature".into()))?;

    // Verify signature
    let is_valid = public_key
        .verify(payload.session_key.as_bytes(), &signature)
        .is_ok();

    if is_valid {
        update_session_verification(&state.pool, payload.session_key, verification.id, is_valid)
            .await?;
    }

    Ok(Json(VerifySignatureResponse { is_valid }))
}
