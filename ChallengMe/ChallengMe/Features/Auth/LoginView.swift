// ============================================================
//  LoginView.swift
//  ChallengMe
// ============================================================

import SwiftUI

struct LoginView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email:        String = ""
    @State private var password:     String = ""
    @State private var showPassword: Bool   = false
    @State private var isLoading:    Bool   = false
    @State private var errorMessage: String?

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var body: some View {
        ZStack {
            DS.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Encabezado ───────────────────────────
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text("Bienvenido\nde vuelta 👋")
                            .font(DS.Font.heading1)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text("Inicia sesión para continuar tus retos")
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.xxl)

                    // ── Campos ───────────────────────────────
                    VStack(spacing: DS.Space.md) {
                        DSTextField(
                            title: "Correo electrónico",
                            placeholder: "tu@correo.com",
                            icon: "envelope",
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        DSSecureField(
                            title: "Contraseña",
                            placeholder: "Mínimo 6 caracteres",
                            text: $password,
                            showPassword: $showPassword
                        )
                    }

                    // ── Olvidé contraseña ────────────────────
                    HStack {
                        Spacer()
                        Button("¿Olvidaste tu contraseña?") {}
                            .font(DS.Font.small)
                            .foregroundStyle(DS.Color.primaryLight)
                    }
                    .padding(.top, DS.Space.sm)

                    // ── Error ────────────────────────────────
                    if let msg = errorMessage {
                        HStack(spacing: DS.Space.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                            Text(msg)
                                .font(DS.Font.small)
                        }
                        .foregroundStyle(DS.Color.danger)
                        .padding(.top, DS.Space.md)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // ── Botón principal ──────────────────────
                    Button {
                        login()
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Iniciar sesión")
                                    .font(DS.Font.heading3)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .background(isFormValid ? DS.Color.primary : DS.Color.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .shadow(color: isFormValid ? DS.Shadow.glowSmColor : .clear,
                            radius: DS.Shadow.glowSmRadius)
                    .disabled(!isFormValid || isLoading)
                    .animation(DS.Animation.standard, value: isFormValid)
                    .padding(.top, DS.Space.xl)

                    // ── Pie ──────────────────────────────────
                    HStack(spacing: DS.Space.xs) {
                        Text("¿No tienes cuenta?")
                            .font(DS.Font.small)
                            .foregroundStyle(DS.Color.textSecondary)

                        NavigationLink(destination: RegisterView()) {
                            Text("Regístrate")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(DS.Color.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.lg)
                }
                .padding(.horizontal, DS.Space.lg)
                .animation(DS.Animation.standard, value: errorMessage)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton { dismiss() }
            }
        }
    }

    // ── Lógica ────────────────────────────────────────────────
    private func login() {
        Task {
            isLoading    = true
            errorMessage = nil
            do {
                try await AuthService.shared.loginEmail(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                // AuthManager.isAuthenticated → true
                // ContentView cambia automáticamente a DashboardView
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environmentObject(AuthManager.shared)
}
