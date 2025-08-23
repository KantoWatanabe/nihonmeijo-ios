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
    //let prefectureNameJa: String
    //let coordinate: CLLocationCoordinate2D
    let isActive: Bool
    
    //let userRating: Int?
    //let userNote: String?
    //let lastVisitedAt: Date?
    //let hasVisited: Bool
}
