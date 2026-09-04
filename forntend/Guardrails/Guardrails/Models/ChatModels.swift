import Foundation


// ============================================================
// REQUEST
// ============================================================

struct ChatRequest: Codable {

    let message: String
}


// ============================================================
// RESPONSE
// ============================================================

struct ChatResponse: Codable {

    let allowed: Bool

    let blockedBy: String?

    let message: String?

    let answer: String?

    let riskScore: Int?

    let model: String?


    enum CodingKeys: String, CodingKey {

        case allowed

        case blockedBy = "blocked_by"

        case message

        case answer

        case riskScore = "risk_score"

        case model
    }
}
