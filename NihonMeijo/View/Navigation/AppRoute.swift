//
//  AppRoute.swift
//  NihonMeijo
//

import SwiftUI

enum AppRoute: Hashable {
    case home
    case help
}

extension AppRoute {
    @ViewBuilder
    func makeView() -> some View {
        switch self {
        case .home:
            HomeView()
        case .help:
            HelpView()
        }
    }
}
