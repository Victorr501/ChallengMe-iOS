// ============================================================
//  MainLayout.swift
//  ChallengMe
//
//  Shell principal de la app tras el login.
//  Contiene el top bar, bottom tab bar y el sheet de perfil.
//  El contenido de cada tab vive en su propia vista.
// ============================================================

import SwiftUI

// ── Definición de tabs ────────────────────────────────────────

enum DashTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case reto      = "Reto"
    case misRetos  = "Mis Retos"
    case ranking   = "Ranking"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .reto:      return "bolt.fill"
        case .misRetos:  return "list.bullet.clipboard.fill"
        case .ranking:   return "trophy.fill"
        }
    }
}

// ── MainLayout ────────────────────────────────────────────────

struct MainLayout: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedTab:     DashTab = .dashboard
    @State private var showProfileSheet = false

    var body: some View {
        ZStack {
            DS.Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.md)
                    .padding(.bottom, DS.Space.sm)

                Divider()
                    .background(DS.Color.border)

                // Ventana activa según el tab seleccionado
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomBar
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileSheet()
                .environmentObject(authManager)
        }
    }

    // ── Top bar ───────────────────────────────────────────────
    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab.rawValue)
                    .font(DS.Font.heading1)
                    .foregroundStyle(DS.Color.textPrimary)
                    .animation(nil, value: selectedTab)

                if let nombre = authManager.claims?.nombreUsuario {
                    Text("Hola, \(nombre) 👋")
                        .font(DS.Font.small)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }

            Spacer()

            Button { showProfileSheet = true } label: {
                ZStack {
                    Circle()
                        .fill(DS.Gradient.racha)
                        .frame(width: 44, height: 44)
                        .shadow(color: DS.Shadow.glowSmColor,
                                radius: DS.Shadow.glowSmRadius)

                    Text(authManager.claims?.nombreUsuario
                            .flatMap { $0.first.map { String($0).uppercased() } } ?? "?")
                        .font(DS.Font.heading3)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // ── Contenido del tab activo ──────────────────────────────
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .dashboard: DashboardView()
        case .reto:      RetoView()
        case .misRetos:  MisRetosView()
        case .ranking:   RankingView()
        }
    }

    // ── Bottom bar ────────────────────────────────────────────
    private var bottomBar: some View {
        HStack(spacing: 0) {
            ForEach(DashTab.allCases) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(DS.Animation.standard) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.top, DS.Space.sm)
        .padding(.bottom, DS.Space.lg)
        .background(
            DS.Color.card
                .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// ── Tab bar button ────────────────────────────────────────────

private struct TabBarButton: View {
    let tab:        DashTab
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Space.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? DS.Color.primary : DS.Color.textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(tab.rawValue)
                    .font(DS.Font.micro)
                    .foregroundStyle(isSelected ? DS.Color.primary : DS.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ── Sheet de perfil ───────────────────────────────────────────

private struct ProfileSheet: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoggingOut = false

    var body: some View {
        ZStack {
            DS.Color.card.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(DS.Color.border)
                    .frame(width: 40, height: 4)
                    .padding(.top, DS.Space.md)

                // Avatar + datos
                VStack(spacing: DS.Space.sm) {
                    ZStack {
                        Circle()
                            .fill(DS.Gradient.racha)
                            .frame(width: 72, height: 72)
                            .shadow(color: DS.Shadow.glowColor, radius: DS.Shadow.glowRadius)

                        Text(authManager.claims?.nombreUsuario
                                .flatMap { $0.first.map { String($0).uppercased() } } ?? "?")
                            .font(DS.Font.heading1)
                            .foregroundStyle(.white)
                    }

                    if let nombre = authManager.claims?.nombreUsuario {
                        Text(nombre)
                            .font(DS.Font.heading2)
                            .foregroundStyle(DS.Color.textPrimary)
                    }

                    if let correo = authManager.claims?.correo {
                        Text(correo)
                            .font(DS.Font.small)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                .padding(.top, DS.Space.xl)
                .padding(.bottom, DS.Space.xxl)

                Divider().background(DS.Color.border)

                // Opciones
                VStack(spacing: 0) {
                    ProfileOption(icon: "person.fill", label: "Perfil") {
                        dismiss()
                        // TODO: navegar a perfil
                    }

                    Divider()
                        .background(DS.Color.border)
                        .padding(.leading, 56)

                    ProfileOption(
                        icon: "rectangle.portrait.and.arrow.right",
                        label: "Cerrar sesión",
                        color: DS.Color.danger,
                        isLoading: isLoggingOut
                    ) {
                        Task {
                            isLoggingOut = true
                            await AuthService.shared.logout()
                            dismiss()
                        }
                    }
                }
                .background(DS.Color.elevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .strokeBorder(DS.Color.border, lineWidth: 1)
                )
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.lg)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

private struct ProfileOption: View {
    let icon:      String
    let label:     String
    var color:     SwiftUI.Color = DS.Color.textPrimary
    var isLoading: Bool = false
    let action:    () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(label)
                    .font(DS.Font.body)
                    .foregroundStyle(color)

                Spacer()

                if isLoading {
                    ProgressView().tint(color)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    MainLayout()
        .environmentObject(AuthManager.shared)
}
