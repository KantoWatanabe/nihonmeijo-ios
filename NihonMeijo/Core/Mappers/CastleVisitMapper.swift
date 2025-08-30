//
//  CastleVisitMapper.swift
//  NihonMeijo
//

import Foundation

struct CastleVisitMapper {
    static func toModel(_ e: CastleVisitEntity) -> CastleVisitModel {
        .init(id: e.id, text: e.text, photoLocalId: e.photoLocalId, order: e.order, castleId: e.castle.id)
    }

    static func toModels(_ entities: [CastleVisitEntity]) -> [CastleVisitModel] {
        entities.map(toModel)
    }
}

struct CastleVisitUpsertParams {
    let id: String
    let text: String
    let photoLocalId: String?
    let order: Int
}

extension CastleVisitUpsertParams {
    static func toUpsertParams(_ model: CastleVisitModel) throws -> CastleVisitUpsertParams {
        .init(id: model.id, text: model.text, photoLocalId: model.photoLocalId, order: model.order)
    }
}
