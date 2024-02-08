//
//  LocationListViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 08.02.2024.
//

import Foundation
protocol LocationListViewModelDelegate: AnyObject {
    func didFetchInitialLoactions()
}

final class LocationListViewModel {
    private var locations: [RMLocation] = [] {
        didSet {
            for location in locations {
                let cellViewModel = LocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(cellViewModel) {
                    cellViewModels.append(cellViewModel)
                }
            }
        }
    }
    weak var delegate: LocationListViewModelDelegate?
    private var apiInfo: RMGetAllLocationsResponse.Info?
    public private(set) var cellViewModels: [LocationTableViewCellViewModel] = []
    
    init() {
    }
    
    public func fetchLocation() {
        RMService.shared.execute(.listLocationsRequest, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLoactions()
                }
            case .failure(let error):
                break
            }
        }
    }
    
    private var hasMoreLocations: Bool {
        return false
    }
}
