//
//  Extensions.swift
//  RMApp
//
//  Created by Albert Garipov on 19.01.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}

