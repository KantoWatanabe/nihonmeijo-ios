//
//  CastleMapper.swift
//  NihonMeijo
//

import Foundation

struct CastleMapper {
    static func toModel(_ e: CastleEntity) -> CastleModel {
        CastleModel(id: e.id, nameJa: e.nameJa, nameKana: e.nameKana, address: e.address, prefecture: PrefCode(rawValue: e.prefecture) ?? .tokyo, isActive: e.isActive, isUserCreated: e.isUserCreated, primaryPhotoLocalId: e.primaryPhotoLocalId, isCleared: e.isCleared, clearedAt: e.clearedAt, rating: e.rating, clearedCostYen: e.clearedCostYen)
    }

    static func toModels(_ entities: [CastleEntity]) -> [CastleModel] {
        entities.map(toModel)
    }
}

struct CastleUpsertParams {
    let id: String
    let nameJa: String
    let nameKana: String
    let address: String
    let prefecture: String
    let lat: Double?
    let lon: Double?
    let isActive: Bool
    let isUserCreated: Bool
    let collections: [CollectionEntity]
}

extension CastleMapper {
    static func toUpsertParams(
        _ dto: CastleDTO,
        resolveCollection: (String) throws -> CollectionEntity,
        isUserCreated: Bool = false
    ) throws -> CastleUpsertParams {

        let cols: [CollectionEntity] = try dto.collectionIds.map { cid in
            try resolveCollection(cid)
        }

        return CastleUpsertParams(
            id: dto.id,
            nameJa: dto.nameJa,
            nameKana: dto.nameKana,
            address: dto.address,
            prefecture: dto.prefecture,
            lat: dto.lat,
            lon: dto.lon,
            isActive: dto.isActive,
            isUserCreated: isUserCreated,
            collections: cols
        )
    }
}
