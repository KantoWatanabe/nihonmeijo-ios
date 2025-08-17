//
//  MasterModel.swift
//  NihonMeijo
//

import Foundation

struct MasterModel: Codable {
    let version: Int
    let castles: [Castle]
    let collections: [CastleCollectionModel]
}

struct Castle: Codable {
    let id: String
    let name: String
}
