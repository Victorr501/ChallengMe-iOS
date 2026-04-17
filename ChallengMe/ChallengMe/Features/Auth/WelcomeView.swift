// ============================================================
//  WelcomeView.swift
//  ChallengMe
//
//  Pantalla principal: elige entre Iniciar sesión o Registrarse
// ============================================================

import SwiftUI

struct WelcomeView: View {

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            // Fondo
            DS.Color.background
                .ignoresSafeArea()

            // Gradiente hero sutil detrás del logo
            GeometryReader { geo in
                DS.Gradient.heroBackground
                    .frame(width: geo.size.width, height: geo.size.height * 0.6)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {

                Spacer()

                // ── Logo + Marca ─────────────────────────────
                VStack(spacing: DS.Space.md) {
                    ZStack {
                        Circle()
                            .fill(DS.Color.primary.opacity(0.15))
                            .frame(width: 110, height: 110)

                        Circle()
                            .strokeBorder(DS.Color.primary.opacity(0.3), lineWidth: 1)
                            .frame(width: 110, height: 110)

                        Image(systemName: "bolt.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DS.Color.primary, DS.Color.accent],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: DS.Shadow.glowColor, radius: DS.Shadow.glowRadius)

                    Text("ChallengMe!")
                        .font(DS.Font.display)
                        .foregroundStyle(DS.Color.textPrimary)

                    Text("Acepta el reto.\nDemuestra lo que vales.")
                        .font(DS.Font.body)
                        .foregroundStyle(DS.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

            

                // ── Botones de acción ────────────────────────
                VStack(spacing: DS.Space.md) {
                    NavigationLink(destination: LoginView()) {
                        Text("Iniciar sesión")
                            .font(DS.Font.heading3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(DS.Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                            .shadow(color: DS.Shadow.glowSmColor, radius: DS.Shadow.glowSmRadius)
                    }

                    NavigationLink(destination: RegisterView()) {
                        Text("Crear cuenta")
                            .font(DS.Font.heading3)
                            .foregroundStyle(DS.Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.md)
                                    .strokeBorder(DS.Color.primary, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, DS.Space.lg)

                // ── Términos ─────────────────────────────────
                Text("Al continuar aceptas los Términos de Uso\ny la Política de Privacidad.")
                    .font(DS.Font.micro)
                    .foregroundStyle(DS.Color.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, DS.Space.md)
                    .padding(.bottom, DS.Space.lg)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear {
            withAnimation(DS.Animation.scaleIn) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// ── Subvistas locales ────────────────────────────────────────

private struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: DS.Space.xs) {
            Text(value)
                .font(DS.Font.heading2)
                .foregroundStyle(DS.Color.primary)
            Text(label)
                .font(DS.Font.micro)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }
}

private struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(DS.Color.border)
            .frame(width: 1, height: 32)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
