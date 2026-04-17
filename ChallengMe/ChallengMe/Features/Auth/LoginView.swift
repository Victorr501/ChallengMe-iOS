// ============================================================
//  LoginView.swift
//  ChallengMe
//
//  Pantalla de inicio de sesión — solo UI, sin peticiones
// ============================================================

import SwiftUI

struct LoginView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false

    // Validación visual mínima
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

                    // ── Botón principal ──────────────────────
                    Button {
                        // sin petición por ahora
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
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
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton { dismiss() }
            }
        }
    }
}

// ── Componentes internos ─────────────────────────────────────

struct DSTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)

            HStack(spacing: DS.Space.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 20)

                TextField("", text: $text, prompt:
                    Text(placeholder).foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                )
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textPrimary)
            }
            .padding(DS.Space.md)
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .strokeBorder(
                        text.isEmpty ? DS.Color.border : DS.Color.primary.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct DSSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)

            HStack(spacing: DS.Space.sm) {
                Image(systemName: "lock")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 20)

                Group {
                    if showPassword {
                        TextField("", text: $text, prompt:
                            Text(placeholder).foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                        )
                    } else {
                        SecureField("", text: $text, prompt:
                            Text(placeholder).foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                        )
                    }
                }
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textPrimary)

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .padding(DS.Space.md)
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .strokeBorder(
                        text.isEmpty ? DS.Color.border : DS.Color.primary.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct DSDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: DS.Space.sm) {
            Rectangle()
                .fill(DS.Color.border)
                .frame(height: 1)

            Text(label)
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)
                .fixedSize()

            Rectangle()
                .fill(DS.Color.border)
                .frame(height: 1)
        }
    }
}

struct SocialButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(DS.Font.heading3)
            }
            .foregroundStyle(DS.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(DS.Color.border, lineWidth: 1)
            )
        }
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(DS.Color.textPrimary)
            .padding(DS.Space.sm)
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
