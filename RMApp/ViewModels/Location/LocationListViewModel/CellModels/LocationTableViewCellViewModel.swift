//
//  LocationTableViewCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 08.02.2024.
//

import Foundation

struct LocationTableViewCellViewModel: Hashable, Equatable {
    
    private let location: RMLocation
    
    init(location: RMLocation) {
        self.location = location
    }
    
    public var name: String {
        return location.name
    }
    
    public var type: String {
        return "Type: "+location.type
    }
    
    public var dimension: String {
        return location.dimension
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.id)
        hasher.combine(dimension)
    }
    
    static func == (lhs: LocationTableViewCellViewModel, rhs: LocationTableViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
