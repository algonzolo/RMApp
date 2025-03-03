//
//  RMEpisode.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import Foundation

struct RMEpisode: Codable, EpisodeDataRender {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
