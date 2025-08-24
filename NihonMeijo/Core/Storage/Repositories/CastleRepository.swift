//
//  CastleRepository.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@MainActor
final class CastleRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func find(by id: String) -> CastleEntity? {
        let fd = FetchDescriptor<CastleEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? context.fetch(fd))?.first
    }
    
    func fetchAll(
        activeOnly: Bool = true,
        sortBy: [SortDescriptor<CastleEntity>] = [
            SortDescriptor(\.id, order: .forward),
        ]
    ) throws -> [CastleEntity] {
        let predicate: Predicate<CastleEntity>? = activeOnly ? #Predicate { $0.isActive } : nil
        let fd = FetchDescriptor<CastleEntity>(predicate: predicate, sortBy: sortBy)
        return try context.fetch(fd)
    }

    func fetchByCollection(
        collectionId: String,
        activeOnly: Bool = true,
        sortBy: [SortDescriptor<CastleEntity>] = [
            SortDescriptor(\.id, order: .forward),
        ]
    ) throws -> [CastleEntity] {
        let predicate: Predicate<CastleEntity> = activeOnly
        ? #Predicate { $0.isActive && $0.collections.contains(where: { $0.id == collectionId }) }
        : #Predicate { $0.collections.contains(where: { $0.id == collectionId }) }

        let fd = FetchDescriptor<CastleEntity>(predicate: predicate, sortBy: sortBy)
        return try context.fetch(fd)
    }

    func upsert(_ p: CastleUpsertParams) throws -> CastleEntity {
        let existing = find(by: p.id)
        let e = existing ?? CastleEntity(
            id: p.id, nameJa: p.nameJa, nameKana: p.nameKana,
            address: p.address, prefecture: p.prefecture,
            lat: p.lat, lon: p.lon, isActive: p.isActive
        )
        e.nameJa = p.nameJa
        e.nameKana = p.nameKana
        e.address = p.address
        e.prefecture = p.prefecture
        e.lat = p.lat
        e.lon = p.lon
        e.isActive = p.isActive
        e.collections = p.collections
        e.updatedAt = .now

        if existing == nil { context.insert(e) }
        try context.save()
        return e
    }

    func delete(_ entity: CastleEntity) throws {
        context.delete(entity)
        try context.save()
    }
    
    func update(_ id: String, mutate: (CastleEntity) throws -> Void) throws {
        guard let e = find(by: id) else { throw AppError.notFound("お城", id: id) }
        try mutate(e)
        e.updatedAt = .now
        try context.save()
    }
    func setPrimaryPhotoLocalId(_ id: String, to localId: String?) throws {
        try update(id) { $0.primaryPhotoLocalId = localId }
    }
    func setCleared(_ id: String, to value: Bool) throws {
        try update(id) { $0.isCleared = value }
    }
    func setClearedDate(_ id: String, date: Date?) throws {
        try update(id) { $0.clearedAt = date }
    }
    func setRating(_ id: String, to value: Int?) throws {
        try update(id) { e in
            if let v = value {
                precondition((1...5).contains(v), "rating must be 1...5")
            }
            e.rating = value
        }
    }
    func setClearedCost(_ id: String, yen: Int?) throws {
        try update(id) { e in
            if let v = yen { precondition(v >= 0, "cost must be >= 0") }
            e.clearedCostYen = yen
        }
    }
}
