//
//  MasterSyncService.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@MainActor
enum MasterSyncService {
    static let masterResourceName = "master"
    static let versionKey = "masterDataVersion"
    
    // MARK: - Public API

    static func syncIfNeeded(
        userDefaults: UserDefaults = .standard
    ) throws {
        let master: MasterDataDTO = ResourceLoader.loadJSON(named: masterResourceName)

        let storedVersion = userDefaults.integer(forKey: versionKey)
        guard storedVersion == 0 || master.version > storedVersion else { return }

        do {
            try sync(master: master, context: StorageProvider.shared.context)
            userDefaults.set(master.version, forKey: versionKey)
        } catch {
            throw AppError.sync("DataSyncService.syncIfNeeded failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Core Sync

    static func sync(
        master: MasterDataDTO,
        context: ModelContext
    ) throws {
        let collectionRepo = CollectionRepository(context: context)
        let castleRepo = CastleRepository(context: context)

        var colMap: [String: CollectionEntity] = [:]
        for c in master.collections {
            let entity = try collectionRepo.upsert(CollectionMapper.toUpsertParams(c))
            colMap[c.id] = entity
        }

        var seenCastleIDs = Set<String>()
        for c in master.castles {
            let params = try CastleMapper.toUpsertParams(c) { cid in
                if let col = colMap[cid] ?? collectionRepo.find(by: cid) {
                    return col
                }
                throw AppError.sync("コレクションID '\(cid)' が見つかりません（マスタ不整合）")
            }

            _ = try castleRepo.upsert(params)
            seenCastleIDs.insert(c.id)
        }

        try deactivateMissingCastles(validIDs: seenCastleIDs, context: context)

        try context.save()
    }

    // MARK: - Helpers

    static func deactivateMissingCastles(
        validIDs: Set<String>,
        context: ModelContext
    ) throws {
        let all = try context.fetch(FetchDescriptor<CastleEntity>())
        for castle in all where !validIDs.contains(castle.id) {
            castle.isActive = false
            castle.updatedAt = .now
        }
    }
}
