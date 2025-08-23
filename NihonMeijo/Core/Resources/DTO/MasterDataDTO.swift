//
//  MasterDataDTO.swift
//  NihonMeijo
//

import Foundation

struct MasterDataDTO: Decodable {
    let version: Int
    let castles: [CastleDTO]
    let collections: [CollectionDTO]
}

struct CastleDTO: Decodable {
    let id: String
    let collectionIds: [String]
    let nameJa: String
    let nameKana: String
    let address: String
    let prefecture: String
    let lat: Double
    let lon: Double
    let isActive: Bool
}

struct CollectionDTO: Decodable {
    let id: String
    let title: String
    let iconName: String
    let order: Int
}
