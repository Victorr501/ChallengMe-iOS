// ============================================================
//  MisRetosView.swift
//  ChallengMe
//
//  Contenido del tab "Mis Retos".
//  El layout (top bar, bottom bar) lo gestiona MainLayout.
// ============================================================

import SwiftUI

struct MisRetosView: View {
    var body: some View {
        ZStack {
            DS.Gradient.heroBackground
                .ignoresSafeArea()

            VStack(spacing: DS.Space.md) {
                Image(systemName: DashTab.misRetos.icon)
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

                Text("Mis Retos")
                    .font(DS.Font.heading2)
                    .foregroundStyle(DS.Color.textPrimary)

                Text("Próximamente…")
                    .font(DS.Font.small)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
    }
}
