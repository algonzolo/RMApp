//
//  CharacterDetailVC.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import UIKit

/// Controller to show info about single characters
final class CharacterDetailVC: UIViewController {
    private let viewModel: CharacterDetailViewModel
    // MARK: - Init
    init(viewModel:CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.title
    }
}
