//
//  SearchView.swift
//  RMApp
//
//  Created by Albert Garipov on 13.02.2024.
//

import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, didSelect option: SearchInputViewModel.DynamicOption)
    func searchView(_ searchView: SearchView, didSelect location: RMLocation)
    func searchView(_ searchView: SearchView, isActive button: Bool)
}

final class SearchView: UIView {
    weak var delegate: SearchViewDelegate?
    private let viewModel: SearchViewModel
    
    private let searchInputView = SearchInputView()
    private let noResultView = NoSearchResultView()
    private let resultView = SearchResultView()
    
    //MARK: - Init
    init(frame: CGRect, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(resultView, noResultView, searchInputView)
        addConstraints()
        searchInputView.configure(with: .init(type: viewModel.config.type))
        searchInputView.delegate = self
        resultView.delegate = self
        setupHandlers(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    
    private func setupHandlers(viewModel: SearchViewModel) {
        viewModel.registerOptionChangeBlock { tuple in
            self.searchInputView.update(option: tuple.0, value: tuple.1)
            }
        
        viewModel.registerSearchResultHandler { [weak self] result in
            DispatchQueue.main.async {
                self?.resultView.configure(with: result)
                self?.noResultView.isHidden = true
                self?.resultView.isHidden = false
            }
        }
        
        viewModel.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultView.isHidden = false
                self?.resultView.isHidden = true
            }
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: viewModel.config.type == .episode ? 60 : 120),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            
            resultView.topAnchor.constraint(equalTo: searchInputView.bottomAnchor),
            resultView.bottomAnchor.constraint(equalTo: bottomAnchor),
            resultView.leftAnchor.constraint(equalTo: leftAnchor),
            resultView.rightAnchor.constraint(equalTo: rightAnchor),
            
            noResultView.widthAnchor.constraint(equalToConstant: 160),
            noResultView.heightAnchor.constraint(equalToConstant: 160),
            noResultView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    //MARK: - Public
    public func presentKeyboard() {
        searchInputView.presentKeyboard()
    }
}

//MARK: - CollectionView
extension SearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .brown
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: - SearchInputViewDelegate
extension SearchView: SearchInputViewDelegate {
    func searchInputViewDidTapSearch(_ inputView: SearchInputView) {
        viewModel.executeSearch()
    }
    
    func searchInputView(_ inputView: SearchInputView, didSelect option: SearchInputViewModel.DynamicOption) {
        delegate?.searchView(self, didSelect: option)
    }
    
    func searchInputView(_ inputView: SearchInputView, didchangeSearchText text: String) {
        viewModel.set(query: text)
    }
    
    func searchInputViewDidTapSearch(_ inputView: SearchInputView, didChangeButtonState isEnabled: Bool) {
        delegate?.searchView(self, isActive: isEnabled)
    }
}

extension SearchView: SearchResultViewDelegate {
    func searchResultView(_ resultsView: SearchResultView, didTapLocationAt index: Int) {
        guard let locationModel = viewModel.locationSearchResult(at: index) else { return }
        delegate?.searchView(self, didSelect: locationModel)
    }
}
