//
//  CastleListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class CastleListViewModel {
    let collection: CollectionModel
    var castles: [CastleModel] = []
    private let repo: CastleRepository

    init(collection: CollectionModel) {
        self.collection = collection
        self.repo = CastleRepository(context: StorageProvider.shared.context)
    }

    func load() {
        do {
            let entities = try repo.fetchByCollection(collectionId: collection.id)
            castles = CastleMapper.toModels(entities)
        } catch {
            castles = []
            print("CastleListViewModel.load error:", error)
        }
    }
}
