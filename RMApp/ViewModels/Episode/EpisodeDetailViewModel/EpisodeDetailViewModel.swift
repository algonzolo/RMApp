//
//  EpisodeDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import UIKit

protocol EpisodeDetailViewModelDelegate: AnyObject {
    func didFetchEpisodeDetails()
}

final class EpisodeDetailViewModel {
    private let endpointURL: URL?
    private var dataTuple: (episode: RMEpisode, characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchEpisodeDetails()
        }
    }
    
    enum SectionType {
        case info(viewModel:[EpisodeDetailCellViewModel] )
        case characters(viewModel: [CharacterCellViewModel])
    }
    
    public weak var delegate: EpisodeDetailViewModelDelegate?
    public private(set) var cellViewModels: [SectionType] = []
    
    //MARK: - Init
    init(endpointURL: URL?) {
        self.endpointURL = endpointURL
        fetchEpisodeData()
    }
    
    //MARK: - Private
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {return}
        let characters = dataTuple.characters
        let episode = dataTuple.episode
        cellViewModels = [
            .info(viewModel: [.init(title: "Name", value: episode.name),
                              .init(title: "Air date", value: episode.air_date),
                              .init(title: "Episode", value: episode.episode),
                              .init(title: "Created", value: episode.created)
            ]),
            .characters(viewModel: characters.compactMap({
                return CharacterCellViewModel(characterName: $0.name,
                                              characterStatus: $0.status,
                                              chracterImageURL: URL(string: $0.image))
            }))
        ]
    }
        
    private func fetchRelatedCharacters(episode: RMEpisode) {
        let charactersURLs : [URL] = episode.characters.compactMap {
            return URL(string: $0)
        }
        
        let requests: [RMRequest] = charactersURLs.compactMap {
            return RMRequest(url: $0)
        }
        
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        
        for request in requests {
            group.enter()
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }
        group.notify(queue: .main) {
            self.dataTuple = (episode:episode, characters:characters)
        }
    }
    
    //MARK: - Public
    public func fetchEpisodeData() {
        guard let url = endpointURL, let request = RMRequest(url: url) else { return }
        RMService.shared.execute(request, expecting: RMEpisode.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(episode: model)
            case .failure:
                break
            }
        }
    }
    
    // MARK: - Layouts
    
    public func createInfoSectionLayout() -> NSCollectionLayoutSection? {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    public func createCharacterSectionLayout() -> NSCollectionLayoutSection? {
    
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.4),
            heightDimension: .fractionalHeight(0.25)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}
