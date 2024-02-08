//
//  SettingsCellViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 07.02.2024.
//

import UIKit

struct SettingsCellViewModel: Identifiable, Hashable {
    let id = UUID()
    private let type: SettingsOption
    
    //MARK: - Init
    init(type: SettingsOption) {
        self.type = type
    }
    
    //MARK: - Public
    public var image: UIImage? {
        return type.iconImage
    }
    
    public var title: String {
        return type.displayTitle
    }
    
    public var iconColor: UIColor {
        return type.iconContainerColor
    }
}
