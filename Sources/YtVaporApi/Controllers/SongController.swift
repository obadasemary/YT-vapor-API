//
//  SongController.swift
//  YtVaporApi
//
//  Created by Abdelrahman Mohamed on 06.02.2026.
//

import Fluent
import Vapor

struct SongController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let songs = routes.grouped("songs")
        
        songs.get(use: index)
        songs.post(use: create)
        let song = songs.grouped(":songID")
        song.put(use: update)
    }
    
    @Sendable
    func index(req: Request) async throws -> [SongDTO] {
        try await Song.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func create(req: Request) async throws -> SongDTO {
        let song = try req.content.decode(SongDTO.self).toModel()
        try await song.save(on: req.db)
        return song.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> SongDTO {
        guard let song = try await Song.find(req.parameters.get("songID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(SongDTO.self)
        if let title = dto.title { song.title = title }
        if let artist = dto.artist { song.artist = artist }
        try await song.save(on: req.db)
        return song.toDTO()
    }
}
