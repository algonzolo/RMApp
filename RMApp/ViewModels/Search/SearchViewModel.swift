//
//  SearchViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 13.02.2024.
//

import Foundation

final class SearchViewModel {
    let config: SearchVC.Config
    private var optionMapUpdateBlock: (((SearchInputViewModel.DynamicOption, String)) -> Void)?
    private var searchText = ""
    private var optionMap: [SearchInputViewModel.DynamicOption: String] = [:]
    private var searchResultHandler: ((SearchResultViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    private var searchResultModel: Codable?
    
    
    //MARK: - Init
    init(config: SearchVC.Config ) {
        self.config = config
    }
    
    //MARK: - Public
    public func registerSearchResultHandler(_ block: @escaping (SearchResultViewModel) -> Void) {
        self.searchResultHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
    }
    
    public func executeSearch() {
        // Build arguments
        var queryParams: [URLQueryItem] = [URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))]
        
        // Add options
        queryParams.append(contentsOf: optionMap.enumerated().compactMap({ _, element in
            let key: SearchInputViewModel.DynamicOption = element.key
            let value: String = element.value
            return URLQueryItem(name: key.queryArgument, value: value)
        }))
        
        // Create request
        let request = RMRequest(endpoint: config.type.endpoint, queryParameters: queryParams)
        
        switch config.type.endpoint {
        case .character:
            makeSearchAPICall(RMGetAllCharactersResponse.self, request: request)
        case .episode:
            makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        case .location:
            makeSearchAPICall(RMGetAllLocationsResponse.self, request: request)
        }
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        RMService.shared.execute(request, expecting: type) { [weak self] result in
            // Notify view of results, no results, or error
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
            case .failure:
                self?.handleNoResult()
                break
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultsVM: SearchResultType?
        var nextURL: String?
        if let characterResults = model as? RMGetAllCharactersResponse {
            resultsVM = .characters(characterResults.results.compactMap({
                return CharacterCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    chracterImageURL: URL(string: $0.image)
                )
            }))
            nextURL = characterResults.info.next
        }
        else if let episodesResults = model as? RMGetAllEpisodesResponse {
            resultsVM = .episodes(episodesResults.results.compactMap({
                return EpisodeCharacterDetailCellViewModel(
                    episodeDataURL: URL(string: $0.url)
                )
            }))
            nextURL = episodesResults.info.next
        }
        else if let locationsResults = model as? RMGetAllLocationsResponse {
            resultsVM = .locations(locationsResults.results.compactMap({
                return LocationTableViewCellViewModel(location: $0)
            }))
            nextURL = locationsResults.info.next
        }

        if let results = resultsVM {
            self.searchResultModel = model
            let vm = SearchResultViewModel(results: results, next: nextURL)
            self.searchResultHandler?(vm)
        } else {
            handleNoResult()
        }
    }
    
    private func handleNoResult() {
        noResultsHandler?()
    }
                               
    public func set(query text: String) {
        self.searchText = text
    }
    
    public func set(value: String, for option: SearchInputViewModel.DynamicOption) {
        optionMap[option] = value
        let tuple = (option, value)
        optionMapUpdateBlock?(tuple)
    }
    
    public func registerOptionChangeBlock(_ block: @escaping ((SearchInputViewModel.DynamicOption, String)) -> Void) {
        self.optionMapUpdateBlock = block
    }
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let searchModel = searchResultModel as? RMGetAllLocationsResponse else { return nil }
        return searchModel.results[index]
    }
    
    public func characterSearchResult(at index: Int) -> RMCharacter? {
        guard let searchModel = searchResultModel as? RMGetAllCharactersResponse else {
            return nil
        }
        return searchModel.results[index]
    }

    public func episodeSearchResult(at index: Int) -> RMEpisode? {
        guard let searchModel = searchResultModel as? RMGetAllEpisodesResponse else {
            return nil
        }
        return searchModel.results[index]
    }
}
