//
//  LocationTableViewCell.swift
//  RMApp
//
//  Created by Albert Garipov on 08.02.2024.
//

import UIKit

final class LocationTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "LocationTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with viewModel:LocationTableViewCellViewModel) {
        
    }
}
