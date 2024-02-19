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
    private var searchResultHandler:  (() -> Void)?
    
    //MARK: - Init
    init(config: SearchVC.Config ) {
        self.config = config
    }
    
    //MARK: - Public
    public func registerSearchResultHandler(_ block: @escaping () -> Void) {
        self.searchResultHandler = block
    }
    public func executeSearch() {
        print("Search text: \(searchText)")
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
        RMService.shared.execute(request, expecting: RMGetAllLocationsResponse.self) { result in
            switch result {
            case .success(let model):
                print("Complete search \(model.results.count)")
            case .failure:
                break
            }
        }
    }
                               
    public func updateText(text text: String) {
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
}
