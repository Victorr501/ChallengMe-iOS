// ============================================================
//  AuthService.swift
//  ChallengMe
//
//  Equivalente Swift de AuthApiService.
//
//  • loginEmail  → POST /api/auth/login-email
//  • register    → POST /api/auth/registro
//  • Login Microsoft y restablecer contraseña: pendientes.
//
//  Tras una respuesta exitosa guarda el JWT en AuthManager
//  (que lo persiste en Keychain y notifica el estado).
// ============================================================

import Foundation

final class AuthService {

    // ── Singleton ────────────────────────────────────────────
    static let shared = AuthService(client: .shared, auth: .shared)

    private let client: APIClient
    private let auth:   AuthManager

    init(client: APIClient, auth: AuthManager) {
        self.client = client
        self.auth   = auth
    }

    // ── Login con email ───────────────────────────────────────
    /// Equivalente: LoginEmailAsync(email, password)
    /// - Returns: AuthResponse con token, id, nombreUsuario y correo
    /// - Throws: APIError si el servidor devuelve error
    @discardableResult
    func loginEmail(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)

        let response: AuthResponse = try await client.send(
            APIConfig.Endpoint.loginEmail,
            method: .POST,
            body: body
        )

        await auth.setToken(response.token)
        return response
    }

    // ── Registro con email ────────────────────────────────────
    /// Equivalente: RegistroEmailAsync(email, password, nombreUsuario)
    /// - Returns: AuthResponse con token, id, nombreUsuario y correo
    /// - Throws: APIError si el servidor devuelve error
    @discardableResult
    func register(
        email: String,
        password: String,
        nombreUsuario: String
    ) async throws -> AuthResponse {
        let body = RegisterRequest(
            Email:         email,
            Password:      password,
            NombreUsuario: nombreUsuario
        )

        let response: AuthResponse = try await client.send(
            APIConfig.Endpoint.registro,
            method: .POST,
            body: body
        )

        await auth.setToken(response.token)
        return response
    }

    // ── Logout ────────────────────────────────────────────────
    func logout() async {
        // Petición al servidor (opcional, ignora errores)
        try? await client.sendVoid(APIConfig.Endpoint.logout, method: .POST)
        await auth.logout()
    }
}
