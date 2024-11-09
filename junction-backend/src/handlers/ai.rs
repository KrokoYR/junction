use async_openai::{
    types::{
        ChatCompletionRequestMessage, ChatCompletionRequestSystemMessage,
        ChatCompletionRequestSystemMessageContent, ChatCompletionRequestUserMessage,
        ChatCompletionRequestUserMessageContent, CreateChatCompletionRequest, ResponseFormat,
    },
    Chat,
};
use axum::{debug_handler, extract::State, Json};

use crate::{error::AppError, AppState};

#[derive(serde::Deserialize)]
pub struct StatementModellingRequest {
    pub statement: String,
}

#[derive(serde::Serialize)]
pub struct StatementModellingResponse {
    pub statement: String,
}

const PROMPT: &str = "
STATEMENT ANALYSIS FRAMEWORK

1. BASIC STATEMENT IDENTIFICATION
- Core proposition/idea
- Primary objective
- Target population/area
- Timeframe for implementation
- Key stakeholders involved

2. CONTEXTUAL ANALYSIS
- Current situation analysis
- Historical context
- Similar initiatives (domestic/international)
- Existing legislation/policies
- Cultural considerations specific to Finland

3. IMPLEMENTATION DIMENSIONS
Economic Impact:
- Initial implementation costs
- Long-term financial implications
- Impact on public budget
- Effect on private sector
- Employment implications
- Regional economic disparities
- International trade implications

Social Impact:
- Demographics affected
- Social equality implications
- Cultural implications
- Community cohesion
- Quality of life changes
- Impact on different age groups
- Gender implications
- Impact on minorities/immigrants

Environmental Impact:
- Carbon footprint
- Resource consumption
- Biodiversity effects
- Waste management implications
- Energy efficiency
- Climate resilience
- Environmental sustainability

Educational Impact:
- Effect on educational system
- Skills development
- Research & innovation
- Academic institutions
- Lifelong learning
- International education standing

Healthcare Impact:
- Public health implications
- Healthcare system strain/benefits
- Mental health considerations
- Preventive care aspects
- Healthcare accessibility
- Healthcare workforce

Technological Impact:
- Digital infrastructure needs
- Innovation requirements
- Tech adoption implications
- Cybersecurity considerations
- Digital inclusion

4. STAKEHOLDER ANALYSIS
- Government bodies affected
- Municipal authorities
- Private sector entities
- NGOs and civil society
- International partners
- Public opinion
- Opposition groups

5. RESOURCE REQUIREMENTS
- Financial resources
- Human capital
- Infrastructure needs
- Technical expertise
- Administrative capacity
- Time resources

6. RISK ASSESSMENT
- Implementation risks
- Financial risks
- Political risks
- Social risks
- Technical risks
- Environmental risks
- International relations risks

7. LEGAL AND REGULATORY FRAMEWORK
- Required legislative changes
- EU compliance
- International agreements
- Municipal regulations
- Industry regulations
- Privacy/data protection

8. TIMELINE AND MILESTONES
- Short-term impacts (0-2 years)
- Medium-term impacts (2-5 years)
- Long-term impacts (5+ years)
- Key implementation phases
- Critical deadlines

9. MONITORING AND EVALUATION
- Success metrics
- Monitoring mechanisms
- Evaluation criteria
- Feedback loops
- Adjustment protocols

10. REGIONAL CONSIDERATIONS
- Urban vs. rural impact
- Regional disparities
- Municipal implications
- Cross-border effects
- Nordic cooperation aspects

11. ALTERNATIVES AND MODIFICATIONS
- Alternative approaches
- Potential modifications
- Hybrid solutions
- Scaling options
- Pilot possibilities

12. SUSTAINABILITY ANALYSIS
- Financial sustainability
- Social sustainability
- Environmental sustainability
- Institutional sustainability
- Political sustainability

13. INTERNATIONAL CONTEXT
- EU implications
- Nordic countries context
- Global positioning
- International competitiveness
- Trade relationships

14. COMMUNICATION STRATEGY
- Public awareness needs
- Stakeholder engagement
- Media relations
- Crisis communication
- International communication

15. SYNERGY ANALYSIS
- Integration with existing systems
- Cross-sector opportunities
- Policy coherence
- Resource optimization
- Innovation potential

For each statement/proposal, analyze:
1. How does it align with Finnish values and society?
2. What are the primary barriers to implementation?
3. What are the unexpected consequences?
4. How does it affect Finland's competitive advantages?
5. What are the critical success factors?
6. How does it contribute to Finland's long-term development?
";

#[debug_handler]
pub async fn statement_modelling(
    State(state): State<AppState>,
    Json(payload): Json<StatementModellingRequest>,
) -> Result<Json<StatementModellingResponse>, AppError> {
    let chat = Chat::new(&state.openai);
    let response = chat
        .create(CreateChatCompletionRequest {
            messages: vec![
                ChatCompletionRequestMessage::System(ChatCompletionRequestSystemMessage {
                    content: ChatCompletionRequestSystemMessageContent::Text(PROMPT.to_string()),
                    name: Some("system".to_string()),
                }),
                ChatCompletionRequestMessage::User(ChatCompletionRequestUserMessage {
                    content: ChatCompletionRequestUserMessageContent::Text(payload.statement),
                    name: Some("user".to_string()),
                }),
            ],
            model: "gpt-4o-2024-08-06".to_string(),
            frequency_penalty: None,
            logit_bias: None,
            logprobs: None,
            top_logprobs: None,
            max_tokens: Some(10000),
            n: Some(1),
            presence_penalty: None,
            response_format: Some(ResponseFormat::Text),
            seed: None,
            service_tier: None,
            stop: None,
            stream: None,
            stream_options: None,
            temperature: Some(0.2),
            top_p: None,
            tools: None,
            tool_choice: None,
            parallel_tool_calls: None,
            user: None,
            function_call: None,
            functions: None,
        })
        .await
        .map_err(|e| {
            println!("Failed to retrieve modelling response: {:?}", e);
            AppError::Internal("Failed to retrieve modelling response".to_string())
        })?;

    let result_statement = response
        .choices
        .into_iter()
        .next()
        .ok_or(AppError::Internal(
            "Failed to retrieve modelling response".to_string(),
        ))?
        .message
        .content
        .unwrap_or("".to_string());

    Ok(Json(StatementModellingResponse {
        statement: result_statement,
    }))
}
