//
//  CollectionMapper.swift
//  NihonMeijo
//

import Foundation

struct CollectionMapper {
    static func toModel(_ e: CollectionEntity) -> CollectionModel {
        CollectionModel(id: e.id, title: e.title, iconName: e.iconName)
    }

    static func toModels(_ entities: [CollectionEntity]) -> [CollectionModel] {
        entities.map(toModel)
    }
}

struct CollectionUpsertParams {
    let id: String
    let title: String
    let iconName: String
    let order: Int
}

extension CollectionMapper {
    static func toUpsertParams(_ dto: CollectionDTO) -> CollectionUpsertParams {
        .init(id: dto.id, title: dto.title, iconName: dto.iconName, order: dto.order)
    }
}
