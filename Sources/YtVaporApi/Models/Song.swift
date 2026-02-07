//
//  Song.swift
//  YtVaporApi
//
//  Created by Abdelrahman Mohamed on 06.02.2026.
//

import Fluent
import Vapor

final class Song: Model, Content, @unchecked Sendable {
    static let schema = "songs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "artist")
    var artist: String?
    
    init() {}
    
    init(id: UUID? = nil, title: String, artist: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
    }
    
    func toDTO() -> SongDTO {
        .init(
            id: self.id,
            title: self.$title.value,
            artist: self.$artist.value ?? nil
        )
    }
}
