//
//  SearchResultViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 19.02.2024.
//

import Foundation

enum SearchResultViewModel {
    case characters([CharacterCellViewModel])
    case episodes([EpisodeCharacterDetailCellViewModel])
    case locations([LocationTableViewCellViewModel])
}
