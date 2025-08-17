//
//  CastleListView.swift
//  NihonMeijo
//

import SwiftUI

struct CastleListView: View {
    let collection: CastleCollectionModel

    var body: some View {
        CastleGridView()
            .navigationTitle(collection.title)
    }
}

struct CastleGridView: View {
    let items: [CastleCellProps] = [
        .init(title: "姫路城", onTap: { print("姫路城 tapped") }),
        .init(title: "大阪城", onTap: { print("大阪城 tapped") }),
        .init(title: "松本城", onTap: { print("松本城 tapped") })
    ]
    
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    CastleCell(props: item)
                }
            }
            .padding(16)
        }
        .navigationTitle("城一覧")
    }
}
