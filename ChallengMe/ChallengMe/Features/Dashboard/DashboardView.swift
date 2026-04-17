// ============================================================
//  DashboardView.swift
//  ChallengMe
//
//  Contenido del tab "Dashboard".
//  El layout (top bar, bottom bar) lo gestiona MainLayout.
// ============================================================

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            DS.Gradient.heroBackground
                .ignoresSafeArea()

            VStack(spacing: DS.Space.md) {
                Image(systemName: DashTab.dashboard.icon)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Color.primary, DS.Color.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: DS.Shadow.glowSmColor,
                            radius: DS.Shadow.glowSmRadius)

                Text("Dashboard")
                    .font(DS.Font.heading2)
                    .foregroundStyle(DS.Color.textPrimary)

                Text("Próximamente…")
                    .font(DS.Font.small)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
    }
}

#Preview {
    MainLayout()
        .environmentObject(AuthManager.shared)
}
