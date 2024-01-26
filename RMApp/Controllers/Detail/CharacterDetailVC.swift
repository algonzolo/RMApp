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
    private let detailView: CharacterDetailView
    
    // MARK: - Init
    init(viewModel:CharacterDetailViewModel) {
        self.viewModel = viewModel
        self.detailView = CharacterDetailView(frame: .zero, viewModel: viewModel)
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
        view.addSubview(detailView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        addConstraint()
        detailView.collectionView?.delegate = self
        detailView.collectionView?.dataSource = self
    }
    
    @objc private func didTapShare() {
        
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

//MARK: - CollectionView
extension CharacterDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.sections[section]
        switch sectionType {
        case .photo:
            return 1
        case .info(viewModels: let viewModels):
            return viewModels.count
        case .episodes(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let sectionType = viewModel.sections[indexPath.section]
        switch sectionType {
        case .photo(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCharacterDetailCell.cellIdentifier, for: indexPath) as? PhotoCharacterDetailCell else { fatalError() }
            cell.configure(with: viewModel)
            cell.backgroundColor = .systemBlue
            return cell
        case .info(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCharacterDetailCell.cellIdentifier, for: indexPath) as? InfoCharacterDetailCell else { fatalError() }
            cell.configure(with: viewModels[indexPath.row])
            cell.backgroundColor = .systemRed
            return cell
        case .episodes(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier, for: indexPath) as? EpisodeCharacterDetailCell else { fatalError() }
            cell.configure(with: viewModels[indexPath.row])
            cell.backgroundColor = .systemGreen
            return cell
        }
    }
}
