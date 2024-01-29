//
//  CharacterDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import UIKit

final class CharacterDetailViewModel {
    private let character: RMCharacter
    public var episodes: [String] {
        character.episode
    }
    
    enum SectionType {
        case photo(viewModel: PhotoCharacterDetailCellViewModel)
        case info(viewModels: [InfoCharacterDetailCellViewModel])
        case episodes(viewModels: [EpisodeCharacterDetailCellViewModel])
    }
    
    public var sections: [SectionType] = []
    
    //MARK: - Init
    init(character: RMCharacter) {
        self.character = character
        setupSections()
    }
    
    private func setupSections() {
        sections = [.photo(viewModel: .init(imageURL: URL(string: character.image))),
                    .info(viewModels: [
                        .init(type: .status, value: character.status.text),
                        .init(type: .gender, value: character.gender.rawValue),
                        .init(type: .type, value: character.type),
                        .init(type: .species, value: character.species),
                        .init(type: .origin, value: character.origin.name),
                        .init(type: .location, value: character.location.name),
                        .init(type: .created, value: character.created),
                        .init(type: .episodeCount, value: "\(character.episode.count)")
                    ]),
                    .episodes(viewModels: character.episode.compactMap({
                        return EpisodeCharacterDetailCellViewModel(episodeDataURL: URL(string: $0))
                    }))
        ]
    }
    
    public var requestURL: URL? {
        return URL(string: character.url)
    }
    
    public var title: String {
        character.name.uppercased()
    }
    
    // MARK: - Layouts
    
    public func createPhotoSectionLayout() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    public func createInfoSectionLayout() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.15)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    public func createEpisodesSectionLayout() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .fractionalHeight(0.15)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}
