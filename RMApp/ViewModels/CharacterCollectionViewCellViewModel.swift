//
//  CharacterCollectionViewCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import Foundation

final class CharacterCollectionViewCellViewModel: Hashable, Equatable {

    public let characterName: String
    private let characterStatus: CharacterStatus
    private let chracterImageURL: URL?
    
    // MARK: - Init
    
    init(
        characterName: String,
        characterStatus: CharacterStatus,
        chracterImageURL: URL?
    ) {
        self.characterName = characterName
        self.characterStatus = characterStatus
        self.chracterImageURL = chracterImageURL
    }
    
    public var characterStatusText: String {
        return "Status: \(characterStatus.text)"
    }
    
    public func fetchImage(completion: @escaping (Result <Data, Error>) -> Void) {
        guard let url = chracterImageURL else {
            completion(.failure(URLError(.badURL)))
            return
        }
        ImageManager.shared.downloadImage(url, completion: completion)
    }
    
    // MARK: - Hashable
    
    static func == (lhs: CharacterCollectionViewCellViewModel, rhs: CharacterCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(chracterImageURL)
    }
}
