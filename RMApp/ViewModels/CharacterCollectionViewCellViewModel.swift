//
//  CharacterCollectionViewCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import Foundation

final class CharacterCollectionViewCellViewModel {
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
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
