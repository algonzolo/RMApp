//
//  RMCharacter.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import Foundation

struct RMCharacter: Codable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: CharacterGender
    let origin: CharacterOrigin
    let location: CharacterLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
}
