//
//  SearchResultView.swift
//  RMApp
//
//  Created by Albert Garipov on 19.02.2024.
//

import UIKit

final class SearchResultView: UIView {
    
    private var viewModel: SearchResultViewModel? {
        didSet {
            self.processViewModel()
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.cellIdentifier)
        return tableView
    }()

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        backgroundColor = .red
        addSubviews(tableView)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        tableView.backgroundColor = .yellow
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else { return }
        
        switch viewModel {
        case .characters(let viewModels):
            setupCollectionView()
        case .episodes(let viewModels):
            setupCollectionView()
        case .locations(let viewModels):
            setupTableView()
        }
    }
    
    private func setupCollectionView() {
        
    }
    
    private func setupTableView() {
        tableView.isHidden = false
    }
    
    public func configure(with viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
    }
}
