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
    private let repo: CollectionRepository

    init() {
        self.repo = CollectionRepository(context: StorageProvider.shared.context)
    }

    func load() {
        do {
            let entities = try repo.fetchAll()
            collections = CollectionMapper.toModels(entities)
        } catch {
            collections = []
            print("HomeViewModel.load error:", error)
        }
    }
}
