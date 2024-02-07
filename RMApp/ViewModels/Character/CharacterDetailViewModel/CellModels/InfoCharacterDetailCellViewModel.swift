//
//  InfoCharacterDetailCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 25.01.2024.
//

import UIKit

final class InfoCharacterDetailCellViewModel {
    
    private let type: `Type`
    private let value: String
    
    public var title: String {
        self.type.displayTitle
    }
    
    public var displayValue: String {
        if value.isEmpty { return "None"}
        if let date = DateFormatter.dateFormatter.date(from: value),
           type == .created {
            return DateFormatter.shortDateFormatter.string(from: date)
        }
        return value
    }
    
    public var iconImage: UIImage? {
        return type.iconImage
    }
    
    enum `Type`: String {
        case status
        case gender
        case type
        case species
        case origin
        case location
        case created
        case episodeCount
        
        var iconImage: UIImage? {
            switch self {
            case .status:
                return UIImage(systemName: "person")
            case .gender:
                return UIImage(systemName: "figure.dress.line.vertical.figure")
            case .type:
                return UIImage(systemName: "shoeprints.fill")
            case .species:
                return UIImage(systemName: "face.dashed")
            case .origin:
                return UIImage(systemName: "tree")
            case .location:
                return UIImage(systemName: "globe")
            case .created:
                return UIImage(systemName: "pencil.tip")
            case .episodeCount:
                return UIImage(systemName: "square.grid.3x3.topleft.filled")
            }
        }
        
        var displayTitle: String {
            switch self {
            case .status,
                 .gender,
                 .type,
                 .species,
                 .origin,
                 .location,
                 .created:
                return rawValue.capitalized
            case .episodeCount:
                return ("Episode Count")
            }
        }
    }
    
    //MARK: - Init
    init(type: `Type`, value: String) {
        self.value = value
        self.type = type
    }
}
