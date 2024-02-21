//
//  SearchResultView.swift
//  RMApp
//
//  Created by Albert Garipov on 19.02.2024.
//

import UIKit

protocol SearchResultViewDelegate: AnyObject {
    func searchResultView(_ resultsView: SearchResultView, didTapLocationAt index: Int)
    func searchResultsView(_ resultsView: SearchResultView, didTapCharacterAt index: Int)
    func searchResultsView(_ resultsView: SearchResultView, didTapEpisodeAt index: Int)
}

final class SearchResultView: UIView {
    
    weak var delegate: SearchResultViewDelegate?
    private var viewModel: SearchResultViewModel? {
        didSet {
            self.processViewModel()
        }
    }
    
    /// TableView viewModels
    private var locationCellViewModels: [LocationTableViewCellViewModel] = []
    /// CollectionView ViewModels
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
        
        switch viewModel.results {
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
        
        guard let viewModel = viewModel else { return }
        switch viewModel.results {
        case .characters:
            delegate?.searchResultsView(self, didTapCharacterAt: indexPath.row)
        case .episodes:
            delegate?.searchResultsView(self, didTapEpisodeAt: indexPath.row)
        case .locations:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentViewModel = collectionCellViewModels[indexPath.row]
        if currentViewModel is CharacterCellViewModel {
            let bounds = collectionView.bounds.width
            let width = (bounds - 30) / 2
            return CGSize(width: width, height: width * 1.5)
        } else {
            return CGSize(width: collectionView.frame.width - 20, height: 100)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FooterLoadingCollectionReusableView.cellIdentifier,
                for: indexPath
              ) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        if let viewModel = viewModel, viewModel.shouldShowLoadMoreIndicator {
            footer.startAnimating()
        }
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = viewModel,
              viewModel.shouldShowLoadMoreIndicator else {
            return .zero
        }

        return CGSize(width: collectionView.frame.width,
                      height: 100)
    }
}

extension SearchResultView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !locationCellViewModels.isEmpty {
            handleLocationPagination(scrollView: scrollView)
        } else {
            handleCharacterOrEpisodePagination(scrollView: scrollView)
        }
    }
    
    private func handleCharacterOrEpisodePagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !collectionCellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                viewModel.fetchAdditionalResults { [weak self] newResults in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.tableFooterView = nil
                        
                        let originalCount = strongSelf.collectionCellViewModels.count
                        let newCount = (newResults.count - originalCount)
                        let total = originalCount + newCount
                        let startingIndex = total - newCount
                        let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                            return IndexPath(row: $0, section: 0)
                        })
                        strongSelf.collectionCellViewModels = newResults
                        strongSelf.collectionView.insertItems(at: indexPathsToAdd)
                    }
                }
            }
            t.invalidate()
        }
    }
    
    private func handleLocationPagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !locationCellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                DispatchQueue.main.async {
                    self?.showTableLoadingIndicator()
                }
                viewModel.fetchAdditionalLocations { [weak self] newResults in
                    // Refresh table
                    self?.tableView.tableFooterView = nil
                    self?.locationCellViewModels = newResults
                    self?.tableView.reloadData()
                }
            }
            t.invalidate()
        }
    }
    
    private func showTableLoadingIndicator() {
        let footer = TableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        tableView.tableFooterView = footer
    }
}

