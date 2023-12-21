//
//  CharacterVC.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import UIKit

final class CharacterVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Characters"
        
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self) { result in
            switch result {
            case .success(let model):
                print(String(describing: model.results))
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
}
