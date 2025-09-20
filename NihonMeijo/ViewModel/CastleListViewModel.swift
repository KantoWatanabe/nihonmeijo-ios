//
//  CastleListViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

enum SortOrder: String, CaseIterable, Identifiable {
    case original
    case ratingDesc
    case visitedDesc
    case costDesc
    var id: Self { self }
}

@MainActor
@Observable
final class CastleListViewModel {
    let collection: CollectionModel
    var castles: [CastleModel] = []
    private let repo: CastleRepository
    private var originalIndex: [String: Int] = [:]

    init(collection: CollectionModel) {
        self.collection = collection
        self.repo = CastleRepository(context: StorageProvider.shared.context)
    }

    func load() {
        do {
            let entities = try repo.fetchByCollection(collectionId: collection.id)
            castles = CastleMapper.toModels(entities)
            originalIndex = Dictionary(uniqueKeysWithValues: castles.enumerated().map { ($0.element.id, $0.offset) })
        } catch {
            castles = []
            originalIndex = [:]
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
                        onlyCleared: Bool? = nil,
                        sort: SortOrder = .original
    ) -> [CastleModel] {
        let q = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1) 状態フィルタ（all/cleared/uncleared）
        let stateFiltered = castles.lazy.filter { c in
            guard let onlyCleared else { return true }
            return onlyCleared ? c.isCleared : !c.isCleared
        }
        
        // 2) 検索（日本語部分一致：名称・かな・都道府県）
        let textFiltered: [CastleModel]
        if q.isEmpty {
            textFiltered = Array(stateFiltered)
        } else {
            textFiltered = stateFiltered.filter { c in
                c.nameJa.localizedCaseInsensitiveContains(q)
                || c.nameKana.localizedCaseInsensitiveContains(q)
                || c.prefecture.rawValue.localizedCaseInsensitiveContains(q)
            }
        }
        
        // 3) 並び替え（nilは末尾、同値は元順）
        let sorted = applySort(textFiltered, by: sort)
        
        if let limit { return Array(sorted.prefix(limit)) }
        return sorted
    }
    
    private func applySort(_ items: [CastleModel], by order: SortOrder) -> [CastleModel] {
        switch order {
        case .original:
            return items.sorted {
                (originalIndex[$0.id] ?? .max) < (originalIndex[$1.id] ?? .max)
            }
        case .ratingDesc:
            return items.sorted {
                let l = $0.rating ?? Int.min
                let r = $1.rating ?? Int.min
                if l == r {
                    return (originalIndex[$0.id] ?? .max) < (originalIndex[$1.id] ?? .max)
                }
                return l > r
            }
        case .visitedDesc:
            return items.sorted {
                switch ($0.clearedAt, $1.clearedAt) {
                case let (l?, r?):
                    if l == r {
                        return (originalIndex[$0.id] ?? .max) < (originalIndex[$1.id] ?? .max)
                    }
                    return l > r
                case (nil, nil):
                    return (originalIndex[$0.id] ?? .max) < (originalIndex[$1.id] ?? .max)
                case (nil, _?):
                    return false // nil は後ろへ
                case (_?, nil):
                    return true
                }
            }
        case .costDesc:
            return items.sorted {
                let l = $0.clearedCostYen ?? Int.min
                let r = $1.clearedCostYen ?? Int.min
                if l == r {
                    return (originalIndex[$0.id] ?? .max) < (originalIndex[$1.id] ?? .max)
                }
                return l > r
            }
        }
    }
}
