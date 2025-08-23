//
//  StorageProvider.swift
//  NihonMeijo
//

import SwiftData

@MainActor
final class StorageProvider {
    static let shared = StorageProvider()

    let container: ModelContainer
    let context: ModelContext

    private init(inMemory: Bool = false) {
        let schema = Schema([
            CastleEntity.self,
            CollectionEntity.self
        ])

        let configuration = ModelConfiguration(
            "NihonMeijoStore",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
            context = container.mainContext
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }
}
