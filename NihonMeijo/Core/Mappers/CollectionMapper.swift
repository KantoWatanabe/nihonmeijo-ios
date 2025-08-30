//
//  CollectionMapper.swift
//  NihonMeijo
//

import Foundation

struct CollectionMapper {
    static func toModel(_ e: CollectionEntity) -> CollectionModel {
        CollectionModel(id: e.id, title: e.title, iconName: e.iconName, order: e.order, isUserCreated: e.isUserCreated)
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
    let isUserCreated: Bool
}

extension CollectionMapper {
    static func toUpsertParams(_ dto: CollectionDTO, isUserCreated: Bool = false) -> CollectionUpsertParams {
        .init(id: dto.id, title: dto.title, iconName: dto.iconName, order: dto.order, isUserCreated: isUserCreated)
    }
}
