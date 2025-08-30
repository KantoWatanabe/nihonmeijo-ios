//
//  CollectionModel.swift
//  NihonMeijo
//

import Foundation

struct CollectionModel: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let iconName: String
    let order: Int
    let isUserCreated: Bool
}
