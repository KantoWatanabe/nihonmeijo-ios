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
    case castleVisitList(CastleModel)
    case castleVisitEditor(CastleModel, CastleVisitModel?)
    case userCollectionList
    case userCollectionEditor(CollectionModel?)
    case userCastleList(CollectionModel)
    case userCastleEditor(CollectionModel, CastleModel?)
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
        case .castleVisitList(let castle):
            CastleVisitListView(castle: castle)
        case .castleVisitEditor(let castle, let editing):
            CastleVisitEditorView(castle: castle, editing: editing)
        case .userCollectionList:
            UserCollectionListView()
        case .userCollectionEditor(let editing):
            UserCollectionEditorView(editing: editing)
        case .userCastleList(let collection):
            UserCastleListView(collection: collection)
        case .userCastleEditor(let collection, let editing):
            UserCastleEditorView(collection: collection, editing: editing)
        }
    }
}
