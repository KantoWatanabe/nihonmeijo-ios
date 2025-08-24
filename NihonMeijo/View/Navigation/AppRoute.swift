//
//  AppRoute.swift
//  NihonMeijo
//

import SwiftUI

enum AppRoute: Hashable {
    case home
    case help
    case castleList(CollectionModel)
    case castleDetail(CastleModel)
}

extension AppRoute {
    @ViewBuilder
    func makeView() -> some View {
        switch self {
        case .home:
            HomeView()
        case .help:
            HelpView()
        case .castleList(let collection):
            CastleListView(collection: collection)
        case .castleDetail(let castle):
            CastleDetailView(castle: castle)
        }
    }
}
