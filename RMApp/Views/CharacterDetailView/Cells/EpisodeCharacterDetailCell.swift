//
//  EpisodeCharacterDetailCell.swift
//  RMApp
//
//  Created by Albert Garipov on 25.01.2024.
//

import UIKit

final class EpisodeCharacterDetailCell: UICollectionViewCell {
    static let cellIdentifier = "EpisodeCharacterDetailCell"
    //MARK: - Properties
    
    private let seasonLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let airDateLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.addSubviews(seasonLabel, nameLabel, airDateLabel)
        setupConstarints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstarints() {
        NSLayoutConstraint.activate([
            seasonLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            seasonLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            seasonLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            seasonLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),
            
            nameLabel.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor, constant: 8),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            nameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),
            
            airDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            airDateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            airDateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            airDateLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        seasonLabel.text = nil
        nameLabel.text = nil
        airDateLabel.text = nil
    }
    
    public func configure(with viewModel: EpisodeCharacterDetailCellViewModel) {
        viewModel.registerForData { [weak self] data in
            self?.nameLabel.text = data.name
            self?.seasonLabel.text = "Episode "+data.episode
            self?.airDateLabel.text = "Aired on "+data.air_date
        }
        viewModel.fetchEpisode()
    }
}
