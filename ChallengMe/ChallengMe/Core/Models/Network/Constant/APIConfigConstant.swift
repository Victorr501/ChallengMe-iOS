//
//  APIConfigConstant.swift
//  ChallengMe
//
//  Created by Victor Rubin on 04/05/2026.
//
import Foundation

enum APIConfigConstant {

    private static func config(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }

    // ── Base URL ─────────────────────────────────────────────
    static var baseURL: URL {
        URL(string: config("API_BASE_URL"))!
    }

    // ── Timeouts (segundos) ──────────────────────────────────
    static let timeoutInterval: TimeInterval = 30

    // ── Headers comunes ──────────────────────────────────────
    static var commonHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept":       "application/json",
        ]
    }

    // ── JWT ──────────────────────────────────────────────────
    enum JWT {
        static var issuer:   String { APIConfigConstant.config("JWT_ISSUER") }
        static var audience: String { APIConfigConstant.config("JWT_AUDIENCE") }
        static let expirationHours = 24
        static let headerKey       = "Authorization"
        static let headerPrefix    = "Bearer"
    }

    // ── Blob Storage ─────────────────────────────────────────
    enum BlobStorage {
        static var containerName: String { APIConfigConstant.config("BLOB_CONTAINER_NAME") }
    }

    // ── Cosmos DB ────────────────────────────────────────────
    enum CosmosDB {
        static var databaseId:  String { APIConfigConstant.config("COSMOS_DATABASE_ID") }
        static var containerId: String { APIConfigConstant.config("COSMOS_CONTAINER_ID") }
    }
}
