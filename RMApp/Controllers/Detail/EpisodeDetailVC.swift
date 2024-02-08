//
//  EpisodeDetailVC.swift
//  RMApp
//
//  Created by Albert Garipov on 29.01.2024.
//

import UIKit

final class EpisodeDetailVC: UIViewController {
    private let viewModel: EpisodeDetailViewModel
    private let detailView = EpisodeDetailView()
    
    // MARK: - Init
    init(url: URL?) {
        //self.viewModel = .init(endpointURL: url)
        self.viewModel = EpisodeDetailViewModel(endpointURL: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Episode"
        view.addSubview(detailView)
        addConstraint()
        viewModel.delegate = self
        viewModel.fetchEpisodeData()
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

extension EpisodeDetailVC: EpisodeDetailViewModelDelegate {
    func didFetchEpisodeDetails() {
        detailView.configure(with: viewModel)
    }
}

//MARK: - CollectionView
extension EpisodeDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sections = viewModel.cellViewModels
        let sectionType = sections[section]
        switch sectionType {
        case .characters(let viewModels):
            return viewModels.count
        case .info(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sections = viewModel.cellViewModels
        let sectionType = sections[indexPath.section]
        switch sectionType {
        case .characters(let viewModels):
            let cellViewModel = viewModels[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.cellIdentifier, for: indexPath) as? CharacterCollectionViewCell else { fatalError() }
            cell.configure(with: cellViewModel)
            return cell
        case .info(let viewModels):
            let cellViewModel = viewModels[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeDetailViewCell.cellIdentifier, for: indexPath) as? EpisodeDetailViewCell else { fatalError() }
            cell.configure(with: cellViewModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let sections = viewModel.cellViewModels
        let sectionType = sections[indexPath.section]
        switch sectionType {
        case .characters:
            guard let character = viewModel.character(at: indexPath.row) else { return }
//            let viewModel = CharacterDetailViewModel(character: character)
            let detailVC = CharacterDetailVC(viewModel: .init(character: character))
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        case .info:
            break
        }
    }
}

