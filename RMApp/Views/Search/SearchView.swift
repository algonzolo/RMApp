//
//  SearchView.swift
//  RMApp
//
//  Created by Albert Garipov on 13.02.2024.
//

import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, didSelect option: SearchInputViewModel.DynamicOption)
}

final class SearchView: UIView {
    weak var delegate: SearchViewDelegate?
    private let viewModel: SearchViewModel
    
    private let searchInputView = SearchInputView()
    private let noResultView = NoSearchResultView()
    
    //MARK: - Init
    init(frame: CGRect, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(noResultView, searchInputView)
        addConstraints()
        searchInputView.configure(with: .init(type: viewModel.config.type))
        searchInputView.delegate = self
        
        viewModel.registerOptionChangeBlock { tuple in
            self.searchInputView.update(option: tuple.0, value: tuple.1)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: viewModel.config.type == .episode ? 60 : 120),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            
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
    func searchInputView(_ inputView: SearchInputView, didSelect option: SearchInputViewModel.DynamicOption) {
        delegate?.searchView(self, didSelect: option)
    }
    
    func searchInputView(_ inputView: SearchInputView, didchangeSearchText text: String) {
        viewModel.updateText(text: text)
    }
    
    func searchInputViewDidTapSearch(_ inputView: SearchInputView) {
        viewModel.executeSearch()
    }
}
