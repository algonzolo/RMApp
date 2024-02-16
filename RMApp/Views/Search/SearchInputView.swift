//
//  SearchInputView.swift
//  RMApp
//
//  Created by Albert Garipov on 13.02.2024.
//

import UIKit

protocol SearchInputViewDelegate: AnyObject {
    func searchInputView(_ inputView: SearchInputView, didSelect option: SearchInputViewModel.DynamicOption)
}

final class SearchInputView: UIView {
    
    weak var delegate: SearchInputViewDelegate?
    
    private var viewModel: SearchInputViewModel? {
        didSet {
            guard let viewModel = viewModel, viewModel.hasDynamicOptions else { return }
            let options = viewModel.options
            createOptionSelectionView(options: options)
        }
    }
    
    private var stackView: UIStackView?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(searchBar)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func createOptionStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center
        addSubviews(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4 ),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        return stackView
    }
    
    private func createButton(with option:SearchInputViewModel.DynamicOption, tag: Int) -> UIButton {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: option.rawValue, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium), .foregroundColor: UIColor.link]), for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        button.tag = tag
        button.layer.cornerRadius = 6
        return button
    }
    
    private func createOptionSelectionView(options: [SearchInputViewModel.DynamicOption] ) {
        let stackView = createOptionStackView()
        self.stackView = stackView
        for x in 0..<options.count {
            let option = options[x]
            let button = createButton(with: option, tag: x)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        guard let options = viewModel?.options else { return }
        let selectedTag = sender.tag
        let selectedOption = options[selectedTag]
        delegate?.searchInputView(self, didSelect: selectedOption)
    }
    
    public func configure(with viewModel: SearchInputViewModel) {
        searchBar.placeholder = viewModel.searchPlaceholderText
        self.viewModel = viewModel
    }
    
    public func presentKeyboard() {
        searchBar.becomeFirstResponder()
    }
    
    public func update(option: SearchInputViewModel.DynamicOption, value: String) {
        guard let buttons = stackView?.arrangedSubviews as? [UIButton], 
              let options = viewModel?.options,
              let index = options.firstIndex(of: option) else { return }
        
        buttons[index].setAttributedTitle(NSAttributedString(string: value.capitalized, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium), .foregroundColor: UIColor.link]), for: .normal)
    }
}
