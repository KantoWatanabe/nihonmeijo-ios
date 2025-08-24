//
//  CastleModel.swift
//  NihonMeijo
//

import Foundation
import CoreLocation

struct CastleModel: Codable, Identifiable, Hashable {
    let id: String
    let nameJa: String
    let nameKana: String
    let address: String
    let prefecture: PrefCode
    //let coordinate: CLLocationCoordinate2D
    let isActive: Bool
    
    var primaryPhotoLocalId: String?
    let isCleared: Bool
    var clearedAt: Date?
    var rating: Int? = nil
    let clearedCostYen: Int?
}
