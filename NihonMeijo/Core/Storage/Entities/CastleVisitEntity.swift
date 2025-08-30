//
//  CastleVisitEntity.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@Model
final class CastleVisitEntity {
    @Attribute(.unique) var id: String

    var text: String
    var photoLocalId: String?
    var order: Int

    @Relationship
    var castle: CastleEntity

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        text: String,
        photoLocalId: String?,
        order: Int,
        castle: CastleEntity
    ) {
        self.id = id
        self.text = text
        self.photoLocalId = photoLocalId
        self.order = order
        self.castle = castle
        self.createdAt = .now
        self.updatedAt = .now
    }
}
