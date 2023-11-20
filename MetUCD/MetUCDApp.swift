//
//  MetUCDApp.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import SwiftUI

@main
struct MetUCDApp: App {
    let viewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView(viewModel: viewModel)
        }
    }
}
