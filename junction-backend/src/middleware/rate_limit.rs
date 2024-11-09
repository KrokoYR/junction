use std::time::Duration;
use tower::limit::RateLimitLayer;
use tower_http::limit::RequestBodyLimitLayer;

pub fn create_rate_limit_layer(requests: u64, duration: u64) -> RateLimitLayer {
    RateLimitLayer::new(requests, Duration::from_secs(duration))
}

pub fn create_body_limit_layer() -> RequestBodyLimitLayer {
    RequestBodyLimitLayer::new(1024 * 1024 * 10) // 10MB limit
}
