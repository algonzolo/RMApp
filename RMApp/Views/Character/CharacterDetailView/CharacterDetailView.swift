//
//  CharacterDetailView.swift
//  RMApp
//
//  Created by Albert Garipov on 22.01.2024.
//

import UIKit

final class CharacterDetailView: UIView {
    
    //MARK: - Properties
    public var collectionView: UICollectionView?
    private let viewModel: CharacterDetailViewModel
    
    //MARK: - Init
    init(frame: CGRect, viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        let collectionView = createCollectionView()
        self.collectionView = collectionView
        addSubviews(collectionView)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        guard let collectionView = collectionView else { return }
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCharacterDetailCell.self, forCellWithReuseIdentifier: PhotoCharacterDetailCell.cellIdentifier)
        collectionView.register(InfoCharacterDetailCell.self, forCellWithReuseIdentifier: InfoCharacterDetailCell.cellIdentifier)
        collectionView.register(EpisodeCharacterDetailCell.self, forCellWithReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        let sectionTypes = viewModel.sections
        
        switch sectionTypes[sectionIndex] {
        case .photo:
            return viewModel.createPhotoSectionLayout()
        case .info:
            return viewModel.createInfoSectionLayout()
        case .episodes:
            return viewModel.createEpisodesSectionLayout()
        }
    }
}
