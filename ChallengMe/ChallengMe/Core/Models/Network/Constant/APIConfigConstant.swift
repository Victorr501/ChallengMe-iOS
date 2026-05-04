//
//  APIConfigConstant.swift
//  ChallengMe
//
//  Created by Victor Rubin on 04/05/2026.
//
import Foundation

enum APIConfigConstant {
    // ── Base URL ─────────────────────────────────────────────
    static let baseURL = URL(string: "https://api-challengeme-ddcpawg6ama0cncn.spaincentral-01.azurewebsites.net/api")!

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
        static let issuer          = "challengeme-api"
        static let audience        = "challengeme-app"
        static let expirationHours = 24               // el token dura 24 h
        static let headerKey       = "Authorization"
        static let headerPrefix    = "Bearer"         // "Bearer <token>"
    }



    // ── Blob Storage ─────────────────────────────────────────
    // Contenedor donde el backend almacena las evidencias
    // (fotos/vídeos) que el usuario sube al completar un reto.
    enum BlobStorage {
        static let containerName = "evidencias"
    }

    // ── Cosmos DB ────────────────────────────────────────────
    // Solo para referencia; el cliente nunca se conecta directo.
    enum CosmosDB {
        static let databaseId  = "challengeme-db"
        static let containerId = "perfiles"
    }
}
