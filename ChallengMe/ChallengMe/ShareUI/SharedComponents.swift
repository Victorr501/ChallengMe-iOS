// ============================================================
//  SharedComponents.swift
//  ChallengMe
//
//  DÓNDE PONERLO: ChallengMe/ChallengMe/ShareUI/SharedComponents.swift
//
//  Componentes reutilizables que usan LoginView y RegisterView:
//    • DSTextField     — campo de texto con título e icono
//    • DSSecureField   — campo de contraseña con ojo toggle
//    • BackButton      — botón de volver atrás de la navbar
// ============================================================

import SwiftUI

// ── DSTextField ───────────────────────────────────────────────
// Equivalente al .form-input + .form-label del CSS.
// Uso:
//   DSTextField(title: "Email", placeholder: "tu@correo.com",
//               icon: "envelope", text: $email)

struct DSTextField: View {

    let title:       String
    let placeholder: String
    let icon:        String        // nombre de SF Symbol
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {

            // Label superior (equivale a .form-label del CSS)
            Text(title.uppercased())
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(0.8)

            // Campo con icono
            HStack(spacing: DS.Space.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isFocused ? DS.Color.primary : DS.Color.textSecondary)
                    .frame(width: 18)
                    .animation(DS.Animation.standard, value: isFocused)

                TextField(placeholder, text: $text)
                    .font(DS.Font.small)
                    .foregroundStyle(DS.Color.textPrimary)
                    .tint(DS.Color.primary)
                    .focused($isFocused)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.vertical, DS.Space.sm + 2)   // ~10px — igual que el CSS
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(
                        isFocused ? DS.Color.primary : DS.Color.border,
                        lineWidth: isFocused ? 1.5 : 1
                    )
                    .animation(DS.Animation.standard, value: isFocused)
            )
            // Glow azul sutil al hacer focus (igual que el CSS box-shadow en :focus)
            .shadow(
                color: isFocused ? DS.Color.primary.opacity(0.2) : .clear,
                radius: 6
            )
            .animation(DS.Animation.standard, value: isFocused)
        }
    }
}

// ── DSSecureField ─────────────────────────────────────────────
// Campo de contraseña con botón ojo para mostrar/ocultar.
// Equivale a .input-password-wrap + .btn-toggle-password del CSS.
// Uso:
//   DSSecureField(title: "Contraseña", placeholder: "Mínimo 6",
//                 text: $password, showPassword: $show)

struct DSSecureField: View {

    let title:       String
    let placeholder: String
    @Binding var text:         String
    @Binding var showPassword: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {

            // Label superior
            Text(title.uppercased())
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(0.8)

            HStack(spacing: DS.Space.sm) {
                Image(systemName: "lock")
                    .font(.system(size: 14))
                    .foregroundStyle(isFocused ? DS.Color.primary : DS.Color.textSecondary)
                    .frame(width: 18)
                    .animation(DS.Animation.standard, value: isFocused)

                // Alterna entre SecureField y TextField según showPassword
                Group {
                    if showPassword {
                        TextField(placeholder, text: $text)
                            .focused($isFocused)
                    } else {
                        SecureField(placeholder, text: $text)
                            .focused($isFocused)
                    }
                }
                .font(DS.Font.small)
                .foregroundStyle(DS.Color.textPrimary)
                .tint(DS.Color.primary)

                // Botón ojo (equivale a .btn-toggle-password del CSS)
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 14))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.vertical, DS.Space.sm + 2)
            .background(DS.Color.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(
                        isFocused ? DS.Color.primary : DS.Color.border,
                        lineWidth: isFocused ? 1.5 : 1
                    )
                    .animation(DS.Animation.standard, value: isFocused)
            )
            .shadow(
                color: isFocused ? DS.Color.primary.opacity(0.2) : .clear,
                radius: 6
            )
            .animation(DS.Animation.standard, value: isFocused)
        }
    }
}

// ── BackButton ────────────────────────────────────────────────
// Botón de volver atrás para la toolbar de navegación.
// Sustituye el botón por defecto de NavigationStack para
// poder usar el color y estilo del Design System.
// Uso:
//   .toolbar {
//       ToolbarItem(placement: .navigationBarLeading) {
//           BackButton { dismiss() }
//       }
//   }

struct BackButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Volver")
                    .font(DS.Font.small)
            }
            .foregroundStyle(DS.Color.primaryLight)
        }
        .buttonStyle(.plain)
    }
}//
//  SharedComponents.swift
//  ChallengMe
//
//  Created by Victor Rubin on 17/04/2026.
//

