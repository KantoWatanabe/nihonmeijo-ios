//
//  CastleVisitRepository.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@MainActor
final class CastleVisitRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func find(by id: String) -> CastleVisitEntity? {
        let fd = FetchDescriptor<CastleVisitEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? context.fetch(fd))?.first
    }

    func fetchByCastleId(
        _ castleId: String,
        sortBy: [SortDescriptor<CastleVisitEntity>] = [SortDescriptor(\.order, order: .forward)]
    ) throws -> [CastleVisitEntity] {
        let fd = FetchDescriptor<CastleVisitEntity>(
            predicate: #Predicate { $0.castle.id == castleId },
            sortBy: sortBy
        )
        return try context.fetch(fd)
    }

    func upsert(_ p: CastleVisitUpsertParams, castle: CastleEntity) throws -> CastleVisitEntity {
        if let existing = find(by: p.id) {
            existing.text = p.text
            existing.photoLocalId = p.photoLocalId
            existing.order = p.order
            existing.updatedAt = .now
            try context.save()
            return existing
        } else {
            let e = CastleVisitEntity(
                id: p.id, text: p.text, photoLocalId: p.photoLocalId,
                order: p.order, castle: castle
            )
            context.insert(e)
            try context.save()
            return e
        }
    }

    func delete(_ entity: CastleVisitEntity) throws {
        context.delete(entity)
        try context.save()
    }

    func applyOrdering(castleId: String, orderedIds: [String]) throws {
        let notes = try fetchByCastleId(castleId)
        let dict = Dictionary(uniqueKeysWithValues: notes.map { ($0.id, $0) })
        for (idx, id) in orderedIds.enumerated() {
            if let e = dict[id], e.order != idx {
                e.order = idx
                e.updatedAt = .now
            }
        }
        try context.save()
    }
}
