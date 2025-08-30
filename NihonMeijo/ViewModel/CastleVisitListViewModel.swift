//
//  CastleVisitListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class CastleVisitListViewModel {
    let castle: CastleModel
    var castleVisits: [CastleVisitModel] = []
    private let repo: CastleVisitRepository
    let castleRepo: CastleRepository

    init(castle: CastleModel) {
        self.castle = castle
        let ctx = StorageProvider.shared.context
        self.repo = CastleVisitRepository(context: ctx)
        self.castleRepo = CastleRepository(context: ctx)
    }

    func load() throws {
        let entities = try repo.fetchByCastleId(
            castle.id,
            sortBy: [
                SortDescriptor(\.order, order: .forward),
                SortDescriptor(\.createdAt, order: .forward)
            ])
        castleVisits = CastleVisitMapper.toModels(entities)
    }
    
    func create(text: String, photoLocalId: String?) throws {
        guard let castleEntity = castleRepo.find(by: castle.id) else { return }
        
        let current = try repo.fetchByCastleId(castle.id)
        let nextOrder = (current.map(\.order).max() ?? -1) + 1
        
        let params = CastleVisitUpsertParams(
            id: UUID().uuidString,
            text: text,
            photoLocalId: photoLocalId,
            order: nextOrder
        )
        
        _ = try repo.upsert(params, castle: castleEntity)
        try load()
    }
    
    func update(item: CastleVisitModel, text: String, photoLocalId: String?) throws {
        guard let castleEntity = castleRepo.find(by: castle.id) else { return }
        let params = CastleVisitUpsertParams(
            id: item.id,
            text: text,
            photoLocalId: photoLocalId,
            order: item.order
        )
        _ = try repo.upsert(params, castle: castleEntity)
        try load()
    }
    
    func delete(item: CastleVisitModel) throws {
        guard let castleVisitEntity = repo.find(by: item.id) else { return }
        try repo.delete(castleVisitEntity)
        try repo.applyOrdering(castleId: castle.id, orderedIds: castleVisits.filter{ $0.id != item.id }.map(\.id))
        try load()
    }
    
    func applyOrdering() throws {
        let orderedIds = castleVisits.map(\.id)
        try repo.applyOrdering(castleId: castle.id, orderedIds: orderedIds)
        try load()
    }
    
    func createAsync(text: String, photoLocalId: String?) async throws {
        try await Self.toAsync { try self.create(text: text, photoLocalId: photoLocalId) }
    }
    func updateAsync(item: CastleVisitModel, text: String, photoLocalId: String?) async throws {
        try await Self.toAsync { try self.update(item: item, text: text, photoLocalId: photoLocalId) }
    }
    func deleteAsync(item: CastleVisitModel) async throws {
        try await Self.toAsync { try self.delete(item: item) }
    }
    func applyOrderingAsync() async throws {
        try await Self.toAsync { try self.applyOrdering() }
    }
    private static func toAsync(_ body: () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try body(); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
}
