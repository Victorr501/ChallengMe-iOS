//
//  ChallengMeApp.swift
//  ChallengMe
//
//  Created by Victor Rubin on 09/04/2026.
//

import SwiftUI

@main
struct ChallengMeApp: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
