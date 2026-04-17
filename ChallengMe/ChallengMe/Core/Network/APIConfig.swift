// ============================================================
//  APIConfig.swift
//  ChallengMe
//
//  Configuración central del servidor.
//  Los secretos (SecretKey, TenantId, ClientId, ClientSecret)
//  viven SOLO en el backend — nunca se envían al cliente.
// ============================================================

import Foundation

enum APIConfig {

    // ── Base URL ─────────────────────────────────────────────
    static let baseURL = URL(string: "https://api-challengeme-ddcpawg6ama0cncn.spaincentral-01.azurewebsites.net/api")!

    // ── Timeouts (segundos) ──────────────────────────────────
    static let timeoutInterval: TimeInterval = 30

    // ── Headers comunes ──────────────────────────────────────
    static var commonHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept":       "application/json",
        ]
    }

    // ── JWT ──────────────────────────────────────────────────
    enum JWT {
        static let issuer          = "challengeme-api"
        static let audience        = "challengeme-app"
        static let expirationHours = 24               // el token dura 24 h
        static let headerKey       = "Authorization"
        static let headerPrefix    = "Bearer"         // "Bearer <token>"
    }



    // ── Blob Storage ─────────────────────────────────────────
    // Contenedor donde el backend almacena las evidencias
    // (fotos/vídeos) que el usuario sube al completar un reto.
    enum BlobStorage {
        static let containerName = "evidencias"
    }

    // ── Cosmos DB ────────────────────────────────────────────
    // Solo para referencia; el cliente nunca se conecta directo.
    enum CosmosDB {
        static let databaseId  = "challengeme-db"
        static let containerId = "perfiles"
    }

    // ── Endpoints ────────────────────────────────────────────
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

    // ── URLRequest factory ───────────────────────────────────
    /// Construye una URLRequest con baseURL + path + headers comunes.
    ///
    /// - Parameters:
    ///   - path:   Ruta relativa, ej. `Endpoint.login`
    ///   - method: Método HTTP (GET por defecto)
    ///   - token:  JWT recibido tras el login; se inyecta como Bearer
    static func request(
        for path: String,
        method: HTTPMethod = .GET,
        token: String? = nil
    ) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)

        var req = URLRequest(url: url, timeoutInterval: timeoutInterval)
        req.httpMethod = method.rawValue

        commonHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let token {
            req.setValue(
                "\(JWT.headerPrefix) \(token)",
                forHTTPHeaderField: JWT.headerKey
            )
        }
        return req
    }
}

// ── Métodos HTTP ─────────────────────────────────────────────
enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}
