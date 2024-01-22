//
//  CharacterListViewModel.swift
//  RMApp
//
//  Created by Albert Garipov on 19.01.2024.
//

import UIKit
protocol CharacterListViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
}

final class CharacterListViewModel: NSObject {
    public weak var delegate: CharacterListViewModelDelegate?
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = CharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    chracterImageURL: URL(string: character.image))
                cellViewModels.append(viewModel)
            }
        }
    }
    private var cellViewModels: [CharacterCollectionViewCellViewModel] = []
    
    func fetchCharacters() {
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let results = responseModel.results
                self?.characters = results
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
}

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds.width
        let width = (bounds - 30) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
}
