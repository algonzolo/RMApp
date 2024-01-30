//
//  EpisodeListView.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import UIKit

protocol EpisodeListViewDelegate: AnyObject {
    func episodeListView( _episodeListView: EpisodeListView, didSelectEpisode episode: RMEpisode)
}

/// View that handles showing list of episodes and etc.
final class EpisodeListView: UIView {
    // MARK: - Properties
    public weak var delegate: EpisodeListViewDelegate?
    private let viewModel = EpisodeListViewModel()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EpisodeCharacterDetailCell.self,
                                forCellWithReuseIdentifier: EpisodeCharacterDetailCell.cellIdentifier)
        collectionView.register(FooterLoadingCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: FooterLoadingCollectionReusableView.cellIdentifier)
        return collectionView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(collectionView, spinner)
        setupConstraints()
        spinner.startAnimating()
        viewModel.delegate = self
        viewModel.fetchEpisodes()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Methods
    private func setupConstraints() {
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
    
    private func setupCollectionView() {
        collectionView.dataSource = viewModel
        collectionView.delegate = viewModel

    }
}

extension EpisodeListView: EpisodeListViewModelDelegate {
    
    func didLoadInitialEpisodes() {
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    func didLoadNextEpisodes(with newIndexPath: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: newIndexPath)
        }
    }
    
    
    func didSelectEpisode(_ episode: RMEpisode) {
        delegate?.episodeListView(_episodeListView: self, didSelectEpisode: episode)
    }
}
