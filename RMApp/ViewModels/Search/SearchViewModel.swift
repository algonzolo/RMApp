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
    
    //MARK: - Init
    init(config: SearchVC.Config ) {
        self.config = config
    }
    
    //MARK: - Public
    public func executeSearch() {
        
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
}
