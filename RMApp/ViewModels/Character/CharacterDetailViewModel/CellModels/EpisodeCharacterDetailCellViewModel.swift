//
//  EpisodeCharacterDetailCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 25.01.2024.
//

import Foundation

protocol EpisodeDataRender {
    var name: String { get }
    var air_date: String { get }
    var episode: String { get }
}

final class EpisodeCharacterDetailCellViewModel: Hashable, Equatable {
    
    private let episodeDataURL: URL?
    private var isFetching = false
    private var dataBlock: ((EpisodeDataRender) -> Void)?
    
    private var episode: RMEpisode? {
        didSet {
            guard let model = episode else { return }
            dataBlock?(model)
        }
    }

    //MARK: - Init
    init(episodeDataURL: URL?) {
        self.episodeDataURL = episodeDataURL
    }
    
    //MARK: - Public Functions
    public func registerForData(_ block: @escaping(EpisodeDataRender) -> Void) {
        self.dataBlock = block
    }
    
    public func fetchEpisode() {
        guard !isFetching else {
            if let model = episode {
                dataBlock?(model)
            }
            return
        }
        
        guard let url = episodeDataURL,
              let request = RMRequest(url: url) else { return }
        isFetching = true
        RMService.shared.execute(request, expecting: RMEpisode.self) { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.episode = model
                }
            case .failure(let failure):
                print(String(String(describing:failure)))
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.episodeDataURL?.absoluteString ?? "")
    }
    
    static func == (lhs: EpisodeCharacterDetailCellViewModel, rhs: EpisodeCharacterDetailCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
