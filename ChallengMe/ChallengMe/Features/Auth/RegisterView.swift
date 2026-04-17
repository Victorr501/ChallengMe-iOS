// ============================================================
//  RegisterView.swift
//  ChallengMe
//
//  Pantalla de registro — solo UI, sin peticiones
// ============================================================

import SwiftUI

struct RegisterView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var acceptedTerms: Bool = false

    // Validación visual
    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6 &&
        passwordsMatch &&
        acceptedTerms
    }

    var body: some View {
        ZStack {
            DS.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Encabezado ───────────────────────────
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text("Crea tu\ncuenta 🚀")
                            .font(DS.Font.heading1)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text("Únete y empieza a superar desafíos hoy")
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.xxl)

                    // ── Campos ───────────────────────────────
                    VStack(spacing: DS.Space.md) {

                        DSTextField(
                            title: "Nombre completo",
                            placeholder: "Tu nombre",
                            icon: "person",
                            text: $name
                        )
                        .textInputAutocapitalization(.words)

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

                        // Confirmación con feedback visual
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            DSSecureField(
                                title: "Confirmar contraseña",
                                placeholder: "Repite tu contraseña",
                                text: $confirmPassword,
                                showPassword: $showConfirmPassword
                            )

                            if !confirmPassword.isEmpty {
                                HStack(spacing: DS.Space.xs) {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 13))
                                    Text(passwordsMatch ? "Las contraseñas coinciden" : "Las contraseñas no coinciden")
                                        .font(DS.Font.micro)
                                }
                                .foregroundStyle(passwordsMatch ? DS.Color.success : DS.Color.danger)
                                .padding(.leading, DS.Space.xs)
                                .animation(DS.Animation.standard, value: passwordsMatch)
                            }
                        }
                    }

                    // ── Indicador de fortaleza ───────────────
                    if !password.isEmpty {
                        PasswordStrengthBar(password: password)
                            .padding(.top, DS.Space.sm)
                    }

                    // ── Términos y condiciones ───────────────
                    Button {
                        withAnimation(DS.Animation.standard) {
                            acceptedTerms.toggle()
                        }
                    } label: {
                        HStack(alignment: .top, spacing: DS.Space.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(
                                        acceptedTerms ? DS.Color.primary : DS.Color.border,
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 20, height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(acceptedTerms ? DS.Color.primary.opacity(0.15) : .clear)
                                    )

                                if acceptedTerms {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(DS.Color.primary)
                                }
                            }

                            Text("Acepto los **Términos de Uso** y la **Política de Privacidad** de ChallengMe")
                                .font(DS.Font.small)
                                .foregroundStyle(DS.Color.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.top, DS.Space.lg)

                    // ── Botón principal ──────────────────────
                    Button {} label: {
                        Text("Crear cuenta")
                            .font(DS.Font.heading3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .background(isFormValid ? DS.Color.primary : DS.Color.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .shadow(color: isFormValid ? DS.Shadow.glowSmColor : .clear,
                            radius: DS.Shadow.glowSmRadius)
                    .disabled(!isFormValid)
                    .animation(DS.Animation.standard, value: isFormValid)
                    .padding(.top, DS.Space.xl)

                    // ── Pie ──────────────────────────────────
                    HStack(spacing: DS.Space.xs) {
                        Text("¿Ya tienes cuenta?")
                            .font(DS.Font.small)
                            .foregroundStyle(DS.Color.textSecondary)

                        Button("Inicia sesión") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.Color.primary)
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

// ── Barra de fortaleza de contraseña ────────────────────────

private struct PasswordStrengthBar: View {

    let password: String

    private var strength: (level: Int, label: String, color: SwiftUI.Color) {
        let count = password.count
        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil

        var score = 0
        if count >= 6 { score += 1 }
        if count >= 10 { score += 1 }
        if hasUpper { score += 1 }
        if hasNumber { score += 1 }
        if hasSpecial { score += 1 }

        switch score {
        case 0...1: return (1, "Muy débil", DS.Color.danger)
        case 2:     return (2, "Débil",     DS.Color.warning)
        case 3:     return (3, "Media",     DS.Color.accent)
        default:    return (4, "Fuerte",    DS.Color.success)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack(spacing: DS.Space.xs) {
                ForEach(1...4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= strength.level ? strength.color : DS.Color.elevated)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .animation(DS.Animation.standard, value: strength.level)
                }
            }

            Text("Fortaleza: \(strength.label)")
                .font(DS.Font.micro)
                .foregroundStyle(strength.color)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
