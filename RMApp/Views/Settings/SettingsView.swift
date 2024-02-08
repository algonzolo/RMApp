//
//  SettingsView.swift
//  RMApp
//
//  Created by Albert Garipov on 07.02.2024.
//

import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.cellViewModels) { viewModel in
            HStack {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color(viewModel.iconColor))
                        .cornerRadius(6)
                        
                }
                Text(viewModel.title)
                    .padding(.leading, 8)
            }
            .padding(.top, 3)
        }
        .listRowSpacing(10)
    }
}

#Preview {
    SettingsView(viewModel: .init(cellViewModels: SettingsOption.allCases.compactMap({
        return SettingsCellViewModel(type: $0)
    })))
}
