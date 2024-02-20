//
//  SearchResultView.swift
//  RMApp
//
//  Created by Albert Garipov on 19.02.2024.
//

import UIKit

protocol SearchResultViewDelegate: AnyObject {
    func searchResultView(_ resultsView: SearchResultView, didTapLocationAt index: Int)
}

final class SearchResultView: UIView {
    
    weak var delegate: SearchResultViewDelegate?
    private var viewModel: SearchResultViewModel? {
        didSet {
            self.processViewModel()
        }
    }
    
    private var locationCellViewModels: [LocationTableViewCellViewModel] = []
    private var collectionCellViewModels: [any Hashable] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.cellIdentifier)
        return tableView
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterCollectionViewCell.self,
                                forCellWithReuseIdentifier: CharacterCollectionViewCell.cellIdentifier)
        collectionView.register(EpisodeCharacterDetailCell.self,
                                forCellWithReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier)
        collectionView.register(FooterLoadingCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: FooterLoadingCollectionReusableView.cellIdentifier)
        return collectionView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        addSubviews(tableView, collectionView)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else { return }
        
        switch viewModel {
        case .characters(let viewModels):
            self.collectionCellViewModels = viewModels
            setupCollectionView()
        case .episodes(let viewModels):
            self.collectionCellViewModels = viewModels
            setupCollectionView()
        case .locations(let viewModels):
            setupTableView(viewModels: viewModels)
        }
    }
    
    private func setupCollectionView() {
        collectionView.reloadData()
        self.tableView.isHidden = true
        self.collectionView.isHidden = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupTableView(viewModels: [LocationTableViewCellViewModel]) {
        self.locationCellViewModels = viewModels
        self.tableView.isHidden = false
        self.collectionView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    public func configure(with viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
    }
}

//MARK: - TableView
extension SearchResultView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.cellIdentifier, for: indexPath) as? LocationTableViewCell else { fatalError() }
        cell.configure(with: locationCellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultView(self, didTapLocationAt: indexPath.row)
    }
}

//MARK: - CollectionView
extension SearchResultView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentViewModel = collectionCellViewModels[indexPath.row]
        
        if let characterViewModel = currentViewModel as? CharacterCellViewModel {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.cellIdentifier, for: indexPath) as? CharacterCollectionViewCell else { fatalError() }
            cell.configure(with: characterViewModel)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier, for: indexPath) as? EpisodeCharacterDetailCell else { fatalError() }
            if let episodeViewModel = currentViewModel as? EpisodeCharacterDetailCellViewModel {
                cell.configure(with: episodeViewModel)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentViewModel = collectionCellViewModels[indexPath.row]
        if currentViewModel is CharacterCellViewModel {
            let bounds = collectionView.bounds.width
            let width = (bounds - 30) / 2
            return CGSize(width: width, height: width * 1.5)
        } else {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
    }
}

