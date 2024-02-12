//
//  LocationTableViewCell.swift
//  RMApp
//
//  Created by Albert Garipov on 08.02.2024.
//

import UIKit

final class LocationTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "LocationTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dimensionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .tertiaryLabel
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(nameLabel, typeLabel, dimensionLabel)
        addConstraints()
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            typeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            
            dimensionLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            dimensionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            dimensionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            dimensionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        typeLabel.text = nil
        dimensionLabel.text = nil
    }
    
    public func configure(with viewModel:LocationTableViewCellViewModel) {
        nameLabel.text = viewModel.name
        typeLabel.text = viewModel.type
        dimensionLabel.text = viewModel.dimension
    }
}
