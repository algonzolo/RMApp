//
//  EpisodeDetailViewCell.swift
//  RMApp
//
//  Created by Albert Garipov on 02.02.2024.
//

import UIKit

/// Single cell for episode
final class EpisodeDetailViewCell: UICollectionViewCell {
    static let cellIdentifier = "EpisodeDetailViewCell"
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemRed
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public
    public func configure(with viewModel: EpisodeDetailCellViewModel) {

    }
}
