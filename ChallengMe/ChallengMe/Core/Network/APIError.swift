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
