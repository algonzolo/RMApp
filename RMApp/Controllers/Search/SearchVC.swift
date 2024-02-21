//
//  SearchVC.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import UIKit

final class SearchVC: UIViewController {

    struct Config {
        enum `Type` {
            case character
            case episode
            case location
            
            var endpoint: RMEndpoint {
                switch self {
                case .character:
                    return .character
                case .episode:
                    return .episode
                case .location:
                    return .location
                }
            }
            
            var title: String {
                switch self {
                case .character:
                    return "Search Characters"
                case .episode:
                    return "Search Episodes"
                case .location:
                    return "Search Locations"
                }
            }
        }
        
        let type: `Type`
    }
   
    private let searchView: SearchView
    private let viewModel: SearchViewModel
    
    //MARK: - Init
    init(config: Config) {
        let viewModel = SearchViewModel(config: config)
        self.viewModel = viewModel
        self.searchView = SearchView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.config.type.title
        view.backgroundColor = .systemBackground
        view.addSubview(searchView)
        addConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(didTapExecuteSearch))
        navigationItem.rightBarButtonItem?.isEnabled = false
        searchView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.presentKeyboard()
    }
    
    @objc private func didTapExecuteSearch() {
        viewModel.executeSearch()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - SearchViewDelegate
extension SearchVC: SearchViewDelegate {
    func searchView(_ searchView: SearchView, isActive button: Bool) {
        button ? (navigationItem.rightBarButtonItem?.isEnabled = true) : (navigationItem.rightBarButtonItem?.isEnabled = false)
    }
        
    func searchView(_ searchView: SearchView, didSelect option: SearchInputViewModel.DynamicOption) {
        let vc = SearchOptionPickerVC(option: option) { [weak self] selection in
            DispatchQueue.main.async {
                self?.viewModel.set(value: selection, for: option)
            }
        }
        
        vc.modalPresentationStyle = .formSheet
        let sheet = vc.sheetPresentationController
        let fraction = UISheetPresentationController.Detent.custom { context in
            CGFloat(option.choices.count) * 40
        }
        sheet?.detents = [fraction]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }
    
    func searchView(_ searchView: SearchView, didSelect location: RMLocation) {
        let vc = LocationDetailVC(location: location)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
