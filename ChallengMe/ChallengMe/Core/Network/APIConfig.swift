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
        let url = APIConfigConstant.baseURL.appendingPathComponent(path)

        var req = URLRequest(url: url, timeoutInterval: APIConfigConstant.timeoutInterval)
        req.httpMethod = method.rawValue

        APIConfigConstant.commonHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let token {
            req.setValue(
                "\(APIConfigConstant.JWT.headerPrefix) \(token)",
                forHTTPHeaderField: APIConfigConstant.JWT.headerKey
            )
        }
        return req
    }
}

// ── Métodos HTTP ─────────────────────────────────────────────
enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}
