// ============================================================
//  AuthManager.swift
//  ChallengMe
//
//  Equivalente Swift de TokenStore + JwtAuthStateProvider.
//
//  • Guarda el JWT en Keychain (nunca en UserDefaults).
//  • Parsea los claims sin librerías externas (Base64 + JSON).
//  • Expone @Published para que las vistas reaccionen al estado.
//  • Notifica logout automático si el token está expirado.
// ============================================================

import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {

    // ── Singleton ────────────────────────────────────────────
    static let shared = AuthManager()

    // ── Estado observable ────────────────────────────────────
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var claims: JWTClaims?

    // ── Keychain key ─────────────────────────────────────────
    private let tokenKey = "com.challengeme.jwt"

    // ── Init: restaura sesión al arrancar ────────────────────
    private init() {
        if let saved = readFromKeychain(), !isExpired(saved) {
            isAuthenticated = true
            claims = parseClaims(saved)
        }
    }

    // ── API pública ──────────────────────────────────────────

    /// Llama a este método tras recibir el JWT del servidor.
    func setToken(_ token: String) {
        guard !isExpired(token) else {
            logout()
            return
        }
        saveToKeychain(token)
        claims = parseClaims(token)
        isAuthenticated = true
    }

    /// Cierra la sesión y borra el token del Keychain.
    func logout() {
        deleteFromKeychain()
        claims = nil
        isAuthenticated = false
    }

    /// Devuelve el token vigente o nil si expiró / no existe.
    /// Si el token guardado está expirado, también hace logout.
    func token() -> String? {
        guard let t = readFromKeychain() else { return nil }
        if isExpired(t) { logout(); return nil }
        return t
    }

    // ── JWT: parseo de claims ─────────────────────────────────

    private func parseClaims(_ token: String) -> JWTClaims? {
        guard let payload = decodePayload(token) else { return nil }
        return JWTClaims(payload: payload)
    }

    private func isExpired(_ token: String) -> Bool {
        guard let payload = decodePayload(token),
              let exp = payload["exp"] as? TimeInterval
        else { return true }
        return Date(timeIntervalSince1970: exp) < Date()
    }

    /// Decodifica el payload (parte central) del JWT sin librerías.
    /// El JWT tiene formato: header.payload.signature — todo en Base64URL.
    private func decodePayload(_ token: String) -> [String: Any]? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }

        // Base64URL → Base64 estándar
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Rellenar hasta múltiplo de 4
        let remainder = base64.count % 4
        if remainder != 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        return json
    }

    // ── Keychain ──────────────────────────────────────────────

    private func saveToKeychain(_ token: String) {
        let data = Data(token.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: tokenKey,
            kSecValueData:   data
        ]
        SecItemDelete(query as CFDictionary)          // borra si ya existe
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      tokenKey,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain() {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// ── JWTClaims ─────────────────────────────────────────────────
// El servidor mete nombre, correo e id dentro del JWT.
// Issuer: "challengeme-api" | Audience: "challengeme-app"

struct JWTClaims {
    // Identidad — nombres que usa el servidor ChallengMe
    let id:            String?   // claim "id" o "sub"
    let nombreUsuario: String?   // claim "nombre" o "name"
    let correo:        String?   // claim "correo" o "email"
    let roles:         [String]  // claim "roles" o "role"

    // Meta del token
    let issuer:    String?       // claim "iss" → "challengeme-api"
    let audience:  String?       // claim "aud" → "challengeme-app"
    let expiresAt: Date?         // claim "exp"
    let issuedAt:  Date?         // claim "iat"

    init(payload: [String: Any]) {
        // id: busca primero "id" (nombre del servidor) y luego "sub" (estándar JWT)
        id            = (payload["id"] as? String) ?? (payload["sub"] as? String)

        // nombre: busca primero "nombre" (servidor) y luego "name" (estándar)
        nombreUsuario = (payload["nombre"] as? String) ?? (payload["name"] as? String)

        // correo: busca primero "correo" (servidor) y luego "email" (estándar)
        correo        = (payload["correo"] as? String) ?? (payload["email"] as? String)

        issuer   = payload["iss"] as? String
        audience = payload["aud"] as? String

        expiresAt = (payload["exp"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
        issuedAt  = (payload["iat"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }

        // "roles" puede llegar como array o como string único
        if let r = payload["roles"] as? [String]     { roles = r }
        else if let r = payload["role"] as? [String] { roles = r }
        else if let r = payload["roles"] as? String  { roles = [r] }
        else if let r = payload["role"] as? String   { roles = [r] }
        else                                         { roles = [] }
    }
}
