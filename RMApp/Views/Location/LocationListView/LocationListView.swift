//
//  LocationListView.swift
//  RMApp
//
//  Created by Albert Garipov on 08.02.2024.
//

import UIKit

protocol LocationListViewDelegate: AnyObject {
    func locationView(_locationView: LocationListView, didSelect location: RMLocation)
}

final class LocationListView: UIView {
    
    public weak var delegate: LocationListViewDelegate?
    
    private var viewModel: LocationListViewModel? {
        didSet {
            spinner.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            }
            
            viewModel?.registerDidFinishPaginationBlock { [weak self] in
                DispatchQueue.main.async {
                    if !(self?.viewModel?.apiInfo?.next != nil) {
                        self?.tableView.tableFooterView = nil
                    }
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alpha = 0
        tableView.isHidden = true
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.cellIdentifier)
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(tableView, spinner)
        spinner.startAnimating()
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo:centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with viewModel: LocationListViewModel) {
        self.viewModel = viewModel
        
    }
}

extension LocationListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cellViewModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModels = viewModel?.cellViewModels else { fatalError() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.cellIdentifier, for: indexPath) as? LocationTableViewCell else { fatalError() }
        
        let cellViewModel = cellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let locationModel = viewModel?.location(at: indexPath.row) else { return }
        delegate?.locationView(_locationView: self, didSelect: locationModel)
    }
}

extension LocationListView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !viewModel.cellViewModels.isEmpty,
              viewModel.shouldShowLoadingIndicator,
              !viewModel.isLoadingMoreLocations  else { return }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.showLoadingIndicator()
                
                viewModel.fetchAdditionalLocations()
            }
            
            timer.invalidate()
        }
    }
    
    private func showLoadingIndicator() {
        let footerView = TableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        footerView.startAnimating()
        tableView.tableFooterView = footerView
    }
}
