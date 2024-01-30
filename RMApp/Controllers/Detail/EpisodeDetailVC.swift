//
//  EpisodeDetailVC.swift
//  RMApp
//
//  Created by Albert Garipov on 29.01.2024.
//

import UIKit

final class EpisodeDetailVC: UIViewController {
    private let viewModel: EpisodeDetailViewModel
    
    // MARK: - Init
    init(url: URL?) {
        self.viewModel = .init(endpointURL: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode"
        view.backgroundColor = .systemBackground
    }
}
