//
//  CharacterListViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 19.01.2024.
//

import UIKit
protocol CharacterListViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didLoadNextCharacters(with newIndexPath: [IndexPath])
    func didSelectCharacter(_ character: RMCharacter)
}

final class CharacterListViewModel: NSObject {
    public weak var delegate: CharacterListViewModelDelegate?
    private var isLoadingCharacters = false
    private var loadMoreCharactersWorkItem: DispatchWorkItem?
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = CharacterCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    chracterImageURL: URL(string: character.image))
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    private var cellViewModels: [CharacterCellViewModel] = []
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
    func fetchCharacters() {
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.characters = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    public func fetchAdditionalCharacters(url: URL) {
        guard !isLoadingCharacters else { return }
        isLoadingCharacters = true
        guard let request = RMRequest(url: url) else {
            isLoadingCharacters = false
            print("Failed to create request")
            return
        }
        
        RMService.shared.execute(request,
                                 expecting: RMGetAllCharactersResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let responseModel):
                let nextResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                
                let initialCount = strongSelf.characters.count
                let newCount = nextResults.count
                let total = initialCount + newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                strongSelf.characters.append(contentsOf: nextResults)
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadNextCharacters(with: indexPathsToAdd)
                    strongSelf.isLoadingCharacters = false
                }
                
            case .failure(let failure):
                print(String(describing: failure))
                strongSelf.isLoadingCharacters = false
            }
        }
    }
    
    public var shouldShowLoadingIndicator: Bool {
        return apiInfo?.next != nil
    }
}

 // MARK: - CollectionView

extension CharacterListViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.cellIdentifier, for: indexPath) as? CharacterCollectionViewCell else {
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
        // TODO: Edit on another screen
        guard shouldShowLoadingIndicator else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds.width
        let width = (bounds - 30) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
    
}

// MARK: - ScrollView
extension CharacterListViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadingIndicator,
              !isLoadingCharacters,
              !cellViewModels.isEmpty,
              let nextPageURL = apiInfo?.next,
              let url = URL(string: nextPageURL) else { return }

        loadMoreCharactersWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalCharacters(url: url)
            }
        }
        
        loadMoreCharactersWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
}
