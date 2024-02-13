//
//  LocationDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 12.02.2024.
//

import UIKit

protocol LocationDetailViewModelDelegate: AnyObject {
    func didFetchLocationDetails()
}

final class LocationDetailViewModel {
    
    private let endpointURL: URL?
    private var dataTuple: (location: RMLocation, characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchLocationDetails()
        }
    }
    
    enum SectionType {
        case info(viewModel:[EpisodeDetailCellViewModel] )
        case characters(viewModel: [CharacterCellViewModel])
    }
    
    public weak var delegate: LocationDetailViewModelDelegate?
    public private(set) var cellViewModels: [SectionType] = []
    
    //MARK: - Init
    init(endpointURL: URL?) {
        self.endpointURL = endpointURL
        fetchLocationData()
    }
    
    public func character(at index: Int) -> RMCharacter? {
        guard let dataTuple = dataTuple else { return nil }
        return dataTuple.characters[index]
    }
    
    //MARK: - Private
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {return}
        let characters = dataTuple.characters
        let location = dataTuple.location
        let date = DateFormatter.dateFormatter.date(from: location.created)!
        let shortDate = DateFormatter.shortDateFormatter.string(from: date)
        
    
        cellViewModels = [
            .info(viewModel: [.init(title: "Location", value: location.name),
                              .init(title: "Type", value: location.type),
                              .init(title: "Dimension", value: location.dimension),
                              .init(title: "Created", value: shortDate)
            ]),
            .characters(viewModel: characters.compactMap({
                return CharacterCellViewModel(characterName: $0.name,
                                              characterStatus: $0.status,
                                              chracterImageURL: URL(string: $0.image))
            }))
        ]
    }
        
    private func fetchRelatedCharacters(location: RMLocation) {
        let charactersURLs : [URL] = location.residents.compactMap {
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
            self.dataTuple = (location:location, characters:characters)
        }
    }
    
    //MARK: - Public
    public func fetchLocationData() {
        guard let url = endpointURL, let request = RMRequest(url: url) else { return }
        RMService.shared.execute(request, expecting: RMLocation.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchRelatedCharacters(location: model)
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
            heightDimension: .absolute(60)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    public func createCharacterSectionLayout() -> NSCollectionLayoutSection? {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.4)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
