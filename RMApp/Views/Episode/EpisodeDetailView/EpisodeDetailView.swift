//
//  EpisodeDetailView.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import UIKit

final class EpisodeDetailView: UIView {
    
    //MARK: - Properties
    public var collectionView: UICollectionView?
    private var viewModel: EpisodeDetailViewModel?

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        let collectionView = createCollectionView()
        self.collectionView = collectionView
        addSubviews(collectionView, spinner)
        addConstraints()
        spinner.startAnimating()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    
    private func addConstraints() {
        guard let collectionView = collectionView else { return }
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo:centerXAnchor),
            
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
        collectionView.register(EpisodeDetailViewCell.self, forCellWithReuseIdentifier: EpisodeDetailViewCell.cellIdentifier)
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.alpha = 0
        return collectionView
    }
    
    private func defaultSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 4, trailing: 2)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    
    private func createSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        guard let sections = viewModel?.cellViewModels else { return defaultSection(for: 0)}
        
        switch sections[sectionIndex] {
        case .info:
            return viewModel?.createInfoSectionLayout() ?? defaultSection(for: 0)
        case .characters:
            return viewModel?.createCharacterSectionLayout() ?? defaultSection(for: 0)
        }
    }
    
    //MARK: - Public
    public func configure(with viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        
        spinner.stopAnimating()
        self.collectionView?.reloadData()
        self.collectionView?.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.collectionView?.alpha = 1
        }
    }
}
