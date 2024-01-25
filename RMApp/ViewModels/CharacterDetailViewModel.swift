//
//  CharacterDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import Foundation

final class CharacterDetailViewModel {
    private let character: RMCharacter
    
    enum SectionType: CaseIterable {
        case photo
        case info
        case episodes
    }
    
    public let sections = SectionType.allCases
    
    //MARK: - Init
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var requestURL: URL? {
        return URL(string: character.url)
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
