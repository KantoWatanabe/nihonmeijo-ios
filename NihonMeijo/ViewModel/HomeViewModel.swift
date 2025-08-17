//
//  HomeViewModel.swift
//  NihonMeijo
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published var collections: [CastleCollectionModel] = []
    
    init() {
        let master: MasterModel = ResourceLoader.loadJSON(named: "master")
        self.collections = master.collections
    }
}
