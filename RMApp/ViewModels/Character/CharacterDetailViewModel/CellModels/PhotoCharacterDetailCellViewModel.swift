//
//  PhotoCharacterDetailCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 25.01.2024.
//

import Foundation

final class PhotoCharacterDetailCellViewModel {
    private let imageURL: URL?
    
    //MARK: - Init
    init(imageURL: URL?) {
        self.imageURL = imageURL
    }
    
    public func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = imageURL else {
            completion(.failure(URLError(.badURL)))
            return
        }
        ImageManager.shared.downloadImage(url, completion: completion)
    }
}
