//
//  CollectionEntity.swift
//  NihonMeijo
//

import Foundation
import SwiftData

@Model
final class CollectionEntity {
    @Attribute(.unique) var id: String
    var title: String
    var iconName: String
    var order: Int

    var castles: [CastleEntity] = []

    var createdAt: Date
    var updatedAt: Date

    init(id: String, title: String, iconName: String, order: Int) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.order = order
        self.createdAt = .now
        self.updatedAt = .now
    }
}
