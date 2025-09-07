//
//  UserCastleListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class UserCastleListViewModel {
    let collection: CollectionModel

    var userCastles: [CastleModel] = []
    private let repo: CastleRepository
    private let collectionRepo: CollectionRepository

    init(collection: CollectionModel) {
        self.collection = collection
        let ctx = StorageProvider.shared.context
        self.repo = CastleRepository(context: ctx)
        self.collectionRepo = CollectionRepository(context: ctx)
    }

    func load() throws {
        let entities = try repo.fetchByCollection(collectionId: collection.id)
        userCastles = CastleMapper.toModels(entities)
    }
    
    func create(nameJa: String, nameKana: String, address: String, prefCode: PrefCode) throws {
        guard let collectionEntity = collectionRepo.find(by: collection.id) else { throw AppError.notFound("コレクション", id: collection.id) }
        let params = CastleUpsertParams(
            id: "user-castle-\(UUID().uuidString)",
            nameJa: nameJa,
            nameKana: nameKana,
            address: address,
            prefecture: prefCode.rawValue,
            lat: nil,
            lon: nil,
            isActive: true,
            isUserCreated: true,
            collections: [ collectionEntity ]
        )
        
        _ = try repo.upsert(params)
        try load()
    }
    
    func update(item: CastleModel, nameJa: String, nameKana: String, address: String, prefCode: PrefCode) throws {
        guard let collectionEntity = collectionRepo.find(by: collection.id) else { throw AppError.notFound("コレクション", id: collection.id) }
        let params = CastleUpsertParams(
            id: item.id,
            nameJa: nameJa,
            nameKana: nameKana,
            address: address,
            prefecture: prefCode.rawValue,
            lat: nil,
            lon: nil,
            isActive: item.isActive,
            isUserCreated: item.isUserCreated,
            collections: [ collectionEntity ]
        )
        _ = try repo.upsert(params)
        try load()
    }
    
    func delete(item: CastleModel) throws {
        guard let castleEntity = repo.find(by: item.id) else { return }
        try repo.delete(castleEntity)
        try load()
    }
    
    func createAsync(nameJa: String, nameKana: String, address: String, prefCode: PrefCode) async throws {
        try await Self.toAsync { try self.create(nameJa: nameJa, nameKana: nameKana, address: address, prefCode: prefCode) }
    }
    func updateAsync(item: CastleModel, nameJa: String, nameKana: String, address: String, prefCode: PrefCode) async throws {
        try await Self.toAsync { try self.update(item: item, nameJa: nameJa, nameKana: nameKana, address: address, prefCode: prefCode) }
    }
    func deleteAsync(item: CastleModel) async throws {
        try await Self.toAsync { try self.delete(item: item) }
    }
    private static func toAsync(_ body: () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try body(); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
}
