//
//  CreateSongs.swift
//  YtVaporApi
//
//  Created by Abdelrahman Mohamed on 06.02.2026.
//

import Fluent

struct CreateSongs: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("songs")
            .id()
            .field("title", .string, .required)
            .field("artist", .string)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("songs")
            .delete()
    }
}
