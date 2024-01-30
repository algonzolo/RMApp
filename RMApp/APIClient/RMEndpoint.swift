//
//  RMEndpoint.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import Foundation

/// Represents unique  API endpoint
@frozen enum RMEndpoint: String, CaseIterable, Hashable {
    case character
    case location
    case episode
}
