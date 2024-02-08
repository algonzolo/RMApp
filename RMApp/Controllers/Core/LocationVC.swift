//
//  LocationVC.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import UIKit

final class LocationVC: UIViewController {
    
    private let locationView = LocationListView()
    private let viewModel = LocationListViewModel()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(locationView)
        view.backgroundColor = .systemBackground
        title = "Locations"
        addSearchButton()
        setupConstraints()
        viewModel.delegate = self
        viewModel.fetchLocation()
    }
    
    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            locationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            locationView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            locationView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
    
    @objc private func didTapSearch() {
        let vc = SearchVC(config: SearchVC.Config(type: .character))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LocationVC: LocationListViewModelDelegate {
    func didFetchInitialLoactions() {
        locationView.configure(with: viewModel)
    }
}

