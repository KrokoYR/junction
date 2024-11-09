mod config;
mod db;
mod error;
mod handlers;
mod middleware;
mod models;
use async_openai::{config::OpenAIConfig, Client};
use axum::{
    error_handling::HandleErrorLayer,
    http::StatusCode,
    routing::{get, post},
    BoxError, Router,
};
use sqlx::postgres::PgPoolOptions;
use tower::{buffer::BufferLayer, ServiceBuilder};
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[derive(Clone)]
struct AppState {
    pool: sqlx::PgPool,
    openai: Client<OpenAIConfig>,
}

#[tokio::main]
async fn main() {
    // Load configuration
    let config = config::Config::from_env().expect("Failed to load configuration");

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Create database connection pool
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&config.database_url)
        .await
        .expect("Failed to create pool");

    // Create OpenAI client
    let openai = Client::new();

    // Create application state
    let state = AppState { pool, openai };

    // Create router with middleware
    let app = Router::new()
        .layer(
            ServiceBuilder::new()
                .layer(HandleErrorLayer::new(|err: BoxError| async move {
                    (
                        StatusCode::INTERNAL_SERVER_ERROR,
                        format!("Unhandled error: {}", err),
                    )
                }))
                .layer(BufferLayer::new(1024))
                .layer(middleware::rate_limit::create_rate_limit_layer(
                    config.rate_limit_requests,
                    config.rate_limit_duration,
                )),
        )
        .layer(TraceLayer::new_for_http())
        .route(
            "/api/user/verify",
            post(handlers::verification::verify_user),
        )
        .route(
            "/api/session/create",
            post(handlers::session::session_create).route_layer(
                ServiceBuilder::new()
                    .layer(HandleErrorLayer::new(|err: BoxError| async move {
                        (
                            StatusCode::INTERNAL_SERVER_ERROR,
                            format!("Unhandled error: {}", err),
                        )
                    }))
                    .layer(BufferLayer::new(1024))
                    .layer(middleware::rate_limit::create_rate_limit_layer(1, 2)),
            ),
        )
        .route(
            "/api/session/is_verified",
            get(handlers::session::is_session_verified),
        )
        .route(
            "/api/signature-verification",
            post(handlers::verify_signature::verify_signature),
        )
        .route(
            "/api/ai/statement-modelling",
            post(handlers::ai::statement_modelling).route_layer(
                ServiceBuilder::new()
                    .layer(HandleErrorLayer::new(|err: BoxError| async move {
                        (
                            StatusCode::INTERNAL_SERVER_ERROR,
                            format!("Unhandled error: {}", err),
                        )
                    }))
                    .layer(BufferLayer::new(1024))
                    .layer(middleware::rate_limit::create_rate_limit_layer(1, 20)),
            ),
        )
        .layer(CorsLayer::very_permissive())
        .with_state(state);

    // Start server
    let listener = tokio::net::TcpListener::bind(&config.server_addr)
        .await
        .unwrap();
    tracing::info!("Server running on {}", config.server_addr);
    axum::serve(listener, app).await.unwrap();
}
