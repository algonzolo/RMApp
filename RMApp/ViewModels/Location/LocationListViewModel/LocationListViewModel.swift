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
    public var isLoadingMoreLocations = false
    public var apiInfo: RMGetAllLocationsResponse.Info?
    public private(set) var cellViewModels: [LocationTableViewCellViewModel] = []
    private var didFinishPagination: (() -> Void)?
    
    //MARK: - Init
    init() {}
    
    public func registerDidFinishPaginationBlock(_ block: @escaping () -> Void) {
        self.didFinishPagination = block
    }
    
    public func location(at index: Int) -> RMLocation? {
        guard index < locations.count, index >= 0 else { return nil }
        return self.locations[index]
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
            case .failure:
                break
            }
        }
    }
    
    public func fetchAdditionalLocations() {
        guard !isLoadingMoreLocations,
        let nextURLString = apiInfo?.next,
        let url = URL(string: nextURLString) else { return }
        
        isLoadingMoreLocations = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreLocations = false
            print("Failed to create request")
            return
        }
        
        RMService.shared.execute(request, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let responseModel):
                let nextResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                strongSelf.cellViewModels.append(contentsOf: nextResults.compactMap({
                    return LocationTableViewCellViewModel(location: $0)
                }))
                
                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreLocations = false

                    // Notify via callback
                    strongSelf.didFinishPagination?()
                }
                
            case .failure(let failure):
                print(String(describing: failure))
                strongSelf.isLoadingMoreLocations = false
            }
        }
    }
    
    public var shouldShowLoadingIndicator: Bool {
        return apiInfo?.next != nil
    }
    
    private var hasMoreLocations: Bool {
        return false
    }
}
