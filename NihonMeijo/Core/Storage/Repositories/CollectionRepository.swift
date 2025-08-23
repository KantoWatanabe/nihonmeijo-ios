//
//  CollectionRepository.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@MainActor
final class CollectionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func find(by id: String) -> CollectionEntity? {
        let fd = FetchDescriptor<CollectionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? context.fetch(fd))?.first
    }

    func fetchAll(
        sortBy: [SortDescriptor<CollectionEntity>] = [SortDescriptor(\.order, order: .forward)]
    ) throws -> [CollectionEntity] {
        let fd = FetchDescriptor<CollectionEntity>(sortBy: sortBy)
        return try context.fetch(fd)
    }

    func upsert(_ p: CollectionUpsertParams) throws -> CollectionEntity {
        if let existing = find(by: p.id) {
            existing.title = p.title
            existing.iconName = p.iconName
            existing.order = p.order
            existing.updatedAt = .now
            try context.save()
            return existing
        } else {
            let entity = CollectionEntity(id: p.id, title: p.title, iconName: p.iconName, order: p.order)
            context.insert(entity)
            try context.save()
            return entity
        }
    }

    func delete(_ entity: CollectionEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
