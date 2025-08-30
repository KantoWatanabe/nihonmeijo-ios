//
//  CastleVisitModel.swift
//  NihonMeijo
//

struct CastleVisitModel: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let photoLocalId: String?
    let order: Int
    let castleId: String
}
