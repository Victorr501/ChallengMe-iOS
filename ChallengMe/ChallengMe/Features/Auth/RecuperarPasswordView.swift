// ============================================================
//  RecuperarPasswordView.swift
//  ChallengMe
// ============================================================

import SwiftUI

private enum RecuperarPasswordEstado: Equatable {
    case inicial
    case cargando
    case enviado
    case error(String)
}

struct RecuperarPasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email:  String = ""
    @State private var estado: RecuperarPasswordEstado = .inicial

    private var isFormValid: Bool {
        // TODO: añadir validación de formato de email (regex)
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isLoading: Bool {
        estado == .cargando
    }

    var body: some View {
        ZStack {
            DS.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Encabezado ───────────────────────────
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text("Restablecer\ncontraseña")
                            .font(DS.Font.heading1)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text("Introduce tu correo y te enviaremos un enlace")
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.xxl)

                    // ── Campo email ──────────────────────────
                    DSTextField(
                        title: "Correo electrónico",
                        placeholder: "tu@correo.com",
                        icon: "envelope",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(estado == .enviado)

                    // ── Feedback ─────────────────────────────
                    Group {
                        switch estado {
                        case .error(let msg):
                            HStack(spacing: DS.Space.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(msg)
                                    .font(DS.Font.small)
                            }
                            .foregroundStyle(DS.Color.danger)

                        case .enviado:
                            HStack(spacing: DS.Space.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Si el correo existe, recibirás un enlace en breve")
                                    .font(DS.Font.small)
                            }
                            .foregroundStyle(DS.Color.success)

                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top, DS.Space.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    // ── Botón enviar ─────────────────────────
                    if estado != .enviado {
                        Button {
                            recuperar()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Enviar enlace")
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
                    }

                    // ── Volver al login ──────────────────────
                    Button {
                        dismiss()
                    } label: {
                        Text("Volver al inicio de sesión")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.Color.primary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.lg)
                }
                .padding(.horizontal, DS.Space.lg)
                .animation(DS.Animation.standard, value: estado)
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
    private func recuperar() {
        Task {
            estado = .cargando
            do {
                try await AuthService.shared.recuperarPassword(
                    email: email.trimmingCharacters(in: .whitespaces)
                )
                estado = .enviado
            } catch {
                estado = .error(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecuperarPasswordView()
    }
    .environmentObject(AuthManager.shared)
}
