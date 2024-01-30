//
//  EpisodeVC.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import UIKit

final class EpisodeVC: UIViewController {
    
    private let episodeListView = EpisodeListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Episodes"
        view.addSubview(episodeListView)
        setupView()
    }
    
    func setupView() {
        episodeListView.delegate = self
        NSLayoutConstraint.activate([
            episodeListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodeListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            episodeListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            episodeListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

extension EpisodeVC: EpisodeListViewDelegate {
    func episodeListView(_episodeListView: EpisodeListView, didSelectEpisode episode: RMEpisode) {
        let detailVC = EpisodeDetailVC(url: URL(string: episode.url))
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
