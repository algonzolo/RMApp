//
//  EpisodeDetailViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import Foundation

final class EpisodeDetailViewModel {
    private let endpointURL: URL?
    
    init(endpointURL: URL?) {
        self.endpointURL = endpointURL
        fetchEpisodeData()
    }
    
    private func fetchEpisodeData() {
        guard let url = endpointURL, let request = RMRequest(url: url) else { return }
        RMService.shared.execute(request, expecting: RMEpisode.self) { result in
            switch result {
            case .success(let success):
                print(String(describing: success))
            case .failure(let failure):
                print(String(describing: failure))
            }
        }
    }
}
