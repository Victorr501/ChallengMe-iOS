//
//  ContentView.swift
//  ChallengMe
//
//  Created by Victor Rubin on 09/04/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        if authManager.isAuthenticated {
            MainLayout()
        } else {
            NavigationStack {
                WelcomeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
