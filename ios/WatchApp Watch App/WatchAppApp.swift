//
//  WatchAppApp.swift
//  WatchApp Watch App
//
//  Created by Scott Hatfield on 11/4/24.
//

import SwiftUI

@main
struct WatchApp_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            LoadingView(viewModel: LoadingViewModel())
        }
    }
}
