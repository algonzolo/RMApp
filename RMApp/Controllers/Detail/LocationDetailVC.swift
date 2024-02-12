//
//  LocationDetailVC.swift
//  RMApp
//
//  Created by Albert Garipov on 12.02.2024.
//

import UIKit

final class LocationDetailVC: UIViewController {
    
    private let viewModel: LocationDetailViewModel
    private let locationlView = LocationDetailView()
    private let location: RMLocation
    
    // MARK: - Init
    init(location: RMLocation) {
        let url = URL(string: location.url)
        self.viewModel = LocationDetailViewModel(endpointURL: url)
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = location.name
        view.addSubview(locationlView)
        addConstraint()
        viewModel.delegate = self
        viewModel.fetchLocationData()
        locationlView.collectionView?.delegate = self
        locationlView.collectionView?.dataSource = self
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            locationlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            locationlView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            locationlView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

extension LocationDetailVC: LocationDetailViewModelDelegate {
    func didFetchLocationDetails() {
        locationlView.configure(with: viewModel)
    }
}

//MARK: - CollectionView
extension LocationDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            let detailVC = CharacterDetailVC(viewModel: .init(character: character))
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        case .info:
            break
        }
    }
}

