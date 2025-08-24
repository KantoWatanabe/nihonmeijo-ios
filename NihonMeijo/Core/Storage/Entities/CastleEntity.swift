//
//  CastleEntity.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@Model
final class CastleEntity {
    @Attribute(.unique) var id: String

    var nameJa: String
    var nameKana: String
    var address: String
    var prefecture: String
    var lat: Double?
    var lon: Double?
    var isActive: Bool

    @Relationship(inverse: \CollectionEntity.castles)
    var collections: [CollectionEntity] = []

    var primaryPhotoLocalId: String? = nil
    var isCleared: Bool
    var clearedAt: Date?
    var rating: Int? = nil
    var clearedCostYen: Int? = nil

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        nameJa: String,
        nameKana: String,
        address: String,
        prefecture: String,
        lat: Double?,
        lon: Double?,
        isActive: Bool
    ) {
        self.id = id
        self.nameJa = nameJa
        self.nameKana = nameKana
        self.address = address
        self.prefecture = prefecture
        self.lat = lat
        self.lon = lon
        self.isActive = isActive
        self.createdAt = .now
        self.updatedAt = .now
        self.isCleared = false
    }
}
