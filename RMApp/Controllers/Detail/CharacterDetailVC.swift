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
        addConstraint()
        detailView.collectionView?.delegate = self
        detailView.collectionView?.dataSource = self
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
            return cell
        case .info(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCharacterDetailCell.cellIdentifier, for: indexPath) as? InfoCharacterDetailCell else { fatalError() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .episodes(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier, for: indexPath) as? EpisodeCharacterDetailCell else { fatalError() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let sectionType = viewModel.sections[indexPath.section]
        switch sectionType {
        case .photo, .info:
            break
        case .episodes:
            let episodes = viewModel.episodes
            let selection = episodes[indexPath.row]
            let vc = EpisodeDetailVC(url: URL(string: selection))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
