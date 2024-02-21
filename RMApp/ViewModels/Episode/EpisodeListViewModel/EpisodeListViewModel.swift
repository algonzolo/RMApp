//
//  EpisodeListViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import UIKit
protocol EpisodeListViewModelDelegate: AnyObject {
    func didLoadInitialEpisodes()
    func didLoadNextEpisodes(with newIndexPath: [IndexPath])
    func didSelectEpisode(_ episode: RMEpisode)
}

final class EpisodeListViewModel: NSObject {
    public weak var delegate: EpisodeListViewModelDelegate?
    private var isLoadingEpisodes = false
    private var episodes: [RMEpisode] = [] {
        didSet {
            for episode in episodes {
                let viewModel = EpisodeCharacterDetailCellViewModel(episodeDataURL: URL(string: episode.url))
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    private var cellViewModels: [EpisodeCharacterDetailCellViewModel] = []
    private var apiInfo: RMGetAllEpisodesResponse.Info? = nil
    
    func fetchEpisodes() {
        RMService.shared.execute(.listEpisodesRequest, expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.episodes = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialEpisodes()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    public func fetchAdditionalEpisodes(url: URL) {
        guard !isLoadingEpisodes else { return }
        isLoadingEpisodes = true
        guard let request = RMRequest(url: url) else {
            isLoadingEpisodes = false
            print("Failed to create request")
            return
        }
        
        RMService.shared.execute(request,
                                 expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let responseModel):
                let nextResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                
                let initialCount = strongSelf.episodes.count
                let newCount = nextResults.count
                let total = initialCount + newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                strongSelf.episodes.append(contentsOf: nextResults)
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadNextEpisodes(with: indexPathsToAdd)
                    strongSelf.isLoadingEpisodes = false
                }
                
            case .failure(let failure):
                print(String(describing: failure))
                strongSelf.isLoadingEpisodes = false
            }
        }
    }
    
    public var shouldShowLoadingIndicator: Bool {
        return apiInfo?.next != nil
    }
}
 // MARK: - CollectionView
extension EpisodeListViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier, for: indexPath) as? EpisodeCharacterDetailCell else {
            fatalError("Unsupported cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: FooterLoadingCollectionReusableView.cellIdentifier,
                                                                     for: indexPath) as? FooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadingIndicator else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let width = bounds.width - 20
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        delegate?.didSelectEpisode(episode)
    }
    
}

// MARK: - ScrollView
extension EpisodeListViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadingIndicator,
              !isLoadingEpisodes,
              !cellViewModels.isEmpty,
              let nextPageURL = apiInfo?.next,
              let url = URL(string: nextPageURL),
              scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 120) else { return }
        
        fetchAdditionalEpisodes(url: url)
    }
}
