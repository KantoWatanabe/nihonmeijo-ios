//
//  HomeViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var collections: [CollectionModel] = []
    var userCollections: [CollectionModel] = []
    private let repo: CollectionRepository

    init() {
        self.repo = CollectionRepository(context: StorageProvider.shared.context)
    }

    func load() throws {
        let entities = try repo.fetchAll()
        let master = entities.filter { !$0.isUserCreated }
        let userCreated = entities.filter { $0.isUserCreated }
        collections = CollectionMapper.toModels(master)
        userCollections = CollectionMapper.toModels(userCreated)
    }
}
