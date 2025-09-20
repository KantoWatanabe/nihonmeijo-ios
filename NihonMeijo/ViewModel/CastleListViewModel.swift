//
//  CastleListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class CastleListViewModel {
    let collection: CollectionModel
    var castles: [CastleModel] = []
    private let repo: CastleRepository

    init(collection: CollectionModel) {
        self.collection = collection
        self.repo = CastleRepository(context: StorageProvider.shared.context)
    }

    func load() {
        do {
            let entities = try repo.fetchByCollection(collectionId: collection.id)
            castles = CastleMapper.toModels(entities)
        } catch {
            castles = []
            print("CastleListViewModel.load error:", error)
        }
    }
    
    var clearedCount: Int {
        castles.filter { $0.isCleared }.count
    }
    var totalCount: Int {
        castles.count
    }
    var clearedPercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(clearedCount) / Double(totalCount)) * 100)
    }
    
    func matchedCastles(for rawQuery: String,
                        limit: Int? = 10,
                        onlyCleared: Bool? = nil) -> [CastleModel] {
        let q = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseSeq = castles.lazy.filter { c in
            if let onlyCleared {
                if onlyCleared && !c.isCleared { return false }
                if !onlyCleared && c.isCleared { return false }
            }
            return true
        }
        guard !q.isEmpty else {
            if let limit { return Array(baseSeq.prefix(limit)) }
            return Array(baseSeq)
        }
        let filtered = baseSeq.filter { c in
            c.nameJa.localizedCaseInsensitiveContains(q)
            || c.nameKana.localizedCaseInsensitiveContains(q)
            || c.prefecture.rawValue.localizedCaseInsensitiveContains(q)
        }
        if let limit { return Array(filtered.prefix(limit)) }
        return Array(filtered)
    }
}
