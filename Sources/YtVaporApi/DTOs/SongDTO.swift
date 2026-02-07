//
//  SongDTO.swift
//  YtVaporApi
//
//  Created by Abdelrahman Mohamed on 07.02.2026.
//

import Fluent
import Vapor

struct SongDTO: Content {
    var id: UUID?
    var title: String?
    var artist: String?
    
    func toModel() -> Song {
        let model = Song()
        
        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        if let artist = self.artist {
            model.artist = artist
        }
        return model
    }
}
