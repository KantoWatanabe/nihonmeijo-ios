//
//  UserCollectionListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class UserCollectionListViewModel {
    var userCollections: [CollectionModel] = []
    private let repo: CollectionRepository
    private let castleRepo: CastleRepository

    init() {
        let ctx = StorageProvider.shared.context
        self.repo = CollectionRepository(context: ctx)
        self.castleRepo = CastleRepository(context: ctx)
    }

    func load() throws {
        let entities = try repo.fetchUserCreated()
        userCollections = CollectionMapper.toModels(entities)
    }
    
    func create(title: String) throws {
        let current = try repo.fetchUserCreated()
        let nextOrder = (current.map(\.order).max() ?? -1) + 1
        
        let params = CollectionUpsertParams(
            id: "user-collection-\(UUID().uuidString)",
            title: title,
            iconName: "Castle",
            order: nextOrder,
            isUserCreated: true
        )
        
        _ = try repo.upsert(params)
        try load()
    }
    
    func update(item: CollectionModel, title: String) throws {
        let params = CollectionUpsertParams(
            id: item.id,
            title: title,
            iconName: item.iconName,
            order: item.order,
            isUserCreated: item.isUserCreated
        )
        _ = try repo.upsert(params)
        try load()
    }
    
    func delete(item: CollectionModel) throws {
        guard let collectionEntity = repo.find(by: item.id) else { return }
        let castles = try castleRepo.fetchByCollection(collectionId: item.id)
        for castle in castles {
            try castleRepo.delete(castle)
        }
        try repo.delete(collectionEntity)
        try repo.applyOrderingUserCreated(orderedIds: userCollections.filter{ $0.id != item.id }.map(\.id))
        try load()
    }
    
    func applyOrderingUserCreated() throws {
        let orderedIds = userCollections.map(\.id)
        try repo.applyOrderingUserCreated(orderedIds: orderedIds)
        try load()
    }
    
    func createAsync(title: String) async throws {
        try await Self.toAsync { try self.create(title: title) }
    }
    func updateAsync(item: CollectionModel, title: String) async throws {
        try await Self.toAsync { try self.update(item: item, title: title) }
    }
    func deleteAsync(item: CollectionModel) async throws {
        try await Self.toAsync { try self.delete(item: item) }
    }
    func applyOrderingUserCreatedAsync() async throws {
        try await Self.toAsync { try self.applyOrderingUserCreated() }
    }
    private static func toAsync(_ body: () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try body(); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
}
