// ============================================================
//  APIClient.swift
//  ChallengMe
//
//  Equivalente Swift de AuthTokenHandler.
//
//  • Intercepta TODAS las peticiones e inyecta el JWT Bearer
//    automáticamente leyéndolo de AuthManager (igual que el
//    DelegatingHandler lee del TokenStore).
//  • Si el servidor devuelve 401 → hace logout automático.
//  • Expone send<T> (con respuesta) y sendVoid (sin respuesta).
// ============================================================

import Foundation

// ── Errores de red ────────────────────────────────────────────

enum APIError: LocalizedError {
    case unauthorized                              // 401 — credenciales inválidas / token expirado
    case conflict(String?)                         // 409 — el email ya existe en registro
    case rateLimited                               // 429 — demasiados intentos (rate limit)
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Correo o contraseña incorrectos."
        case .conflict(let msg):
            return msg ?? "El correo ya está registrado."
        case .rateLimited:
            return "Demasiados intentos. Espera un momento e inténtalo de nuevo."
        case .serverError(let code, let msg):
            return "Error del servidor (\(code))\(msg.map { ": \($0)" } ?? "")."
        case .decodingError(let e):
            return "No se pudo procesar la respuesta: \(e.localizedDescription)"
        case .networkError(let e):
            return "Error de red: \(e.localizedDescription)"
        }
    }
}

// ── APIClient ─────────────────────────────────────────────────

final class APIClient {

    // ── Singleton ────────────────────────────────────────────
    static let shared = APIClient(auth: .shared)

    private let session: URLSession
    private let auth: AuthManager

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy  = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy  = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    init(auth: AuthManager) {
        self.auth    = auth
        self.session = URLSession(configuration: .default)
    }

    // ── Petición con respuesta decodificable ──────────────────
    /// Uso:
    ///   let user: UserDTO = try await APIClient.shared.send(APIConfig.Endpoint.me)
    func send<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil
    ) async throws -> T {
        let req = try await buildRequest(path: path, method: method, body: body)
        let (data, response) = try await perform(req)
        return try decode(T.self, from: data, response: response)
    }

    // ── Petición sin respuesta (201 Created, 204 No Content…) ─
    /// Uso:
    ///   try await APIClient.shared.sendVoid(APIConfig.Endpoint.logout, method: .POST)
    func sendVoid(
        _ path: String,
        method: HTTPMethod = .POST,
        body: (any Encodable)? = nil
    ) async throws {
        let req = try await buildRequest(path: path, method: method, body: body)
        let (_, response) = try await perform(req)
        try validateStatus(response, data: Data())
    }

    // ── Subida de archivo (evidencias / avatar) ───────────────
    /// Sube datos binarios (imagen, vídeo) con multipart/form-data.
    /// Uso:
    ///   try await APIClient.shared.upload(data: imageData,
    ///                                     mimeType: "image/jpeg",
    ///                                     to: APIConfig.Endpoint.evidence(challengeId: id))
    func upload(
        data fileData: Data,
        mimeType: String,
        fieldName: String = "file",
        to path: String,
        method: HTTPMethod = .POST
    ) async throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        let token = await auth.token()

        var req = APIConfig.request(for: path, method: method, token: token)
        req.setValue("multipart/form-data; boundary=\(boundary)",
                     forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".utf8Data)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"upload\"\r\n".utf8Data)
        body.append("Content-Type: \(mimeType)\r\n\r\n".utf8Data)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".utf8Data)
        req.httpBody = body

        let (_, response) = try await perform(req)
        try validateStatus(response, data: Data())
    }

    // ── Internos ──────────────────────────────────────────────

    private func buildRequest(
        path: String,
        method: HTTPMethod,
        body: (any Encodable)?
    ) async throws -> URLRequest {
        let token = await auth.token()
        var req = APIConfig.request(for: path, method: method, token: token)

        if let body {
            req.httpBody = try encoder.encode(body)
        }
        return req
    }

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.networkError(URLError(.badServerResponse))
            }
            return (data, http)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data, response: HTTPURLResponse) throws -> T {
        try validateStatus(response, data: data)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    @discardableResult
    private func validateStatus(_ response: HTTPURLResponse, data: Data) throws -> HTTPURLResponse {
        switch response.statusCode {
        case 200...299:
            return response
        case 401:
            Task { @MainActor in await auth.logout() }
            throw APIError.unauthorized
        case 409:
            let msg = String(data: data, encoding: .utf8)
            throw APIError.conflict(msg)
        case 429:
            throw APIError.rateLimited
        default:
            let msg = String(data: data, encoding: .utf8)
            throw APIError.serverError(statusCode: response.statusCode, message: msg)
        }
    }
}

// ── Helper: String → Data ─────────────────────────────────────
private extension String {
    var utf8Data: Data { Data(utf8) }
}
