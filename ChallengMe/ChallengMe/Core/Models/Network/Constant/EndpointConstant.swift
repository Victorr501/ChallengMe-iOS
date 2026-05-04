enum Endpoint {

    // Auth
    static let loginEmail    = "/auth/login-email"
    static let registro      = "/auth/registro"
    static let refreshToken  = "/auth/refresh"
    static let logout        = "/auth/logout"

    // Evidencias (BlobStorage → "evidencias")
    static func evidence(challengeId: String) -> String {
        "/challenges/\(challengeId)/evidence"
    }

    // Ranking
    static let leaderboard = "/leaderboard"

    // TODO: añadir el resto de endpoints conforme se definan
}
