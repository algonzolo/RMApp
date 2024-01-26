//
//  InfoCharacterDetailCell.swift
//  RMApp
//
//  Created by Albert Garipov on 25.01.2024.
//

import UIKit

final class InfoCharacterDetailCell: UICollectionViewCell {
    static let cellIdentifier = "InfoCharacterDetailCell"
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstarints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstarints() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with viewModel: InfoCharacterDetailCellViewModel) {
        
    }
}
