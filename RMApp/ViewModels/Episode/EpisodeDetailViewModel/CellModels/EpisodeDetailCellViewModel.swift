//
//  EpisodeDetailCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 02.02.2024.
//

import Foundation

final class EpisodeDetailCellViewModel {
    public let title: String
    public let value: String
    
    // MARK: - Init
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}
