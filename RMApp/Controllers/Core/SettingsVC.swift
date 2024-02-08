//
//  SettingsVC.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import UIKit
import SwiftUI

final class SettingsVC: UIViewController {
    
    private let settingsVC = UIHostingController(rootView: SettingsView(viewModel: SettingsViewModel(cellViewModels: SettingsOption.allCases.compactMap({
        return SettingsCellViewModel(type: $0)
    }))))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        addChildVC()
    }
    
    private func addChildVC() {
        addChild(settingsVC)
        settingsVC.didMove(toParent: self)
        
        view.addSubview(settingsVC.view)
        settingsVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            settingsVC.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            settingsVC.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
}
