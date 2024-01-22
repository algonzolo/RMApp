//
//  CharacterDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import Foundation

final class CharacterDetailViewModel {
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
