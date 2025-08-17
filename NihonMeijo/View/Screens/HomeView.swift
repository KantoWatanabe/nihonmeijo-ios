//
//  HomeView.swift
//  NihonMeijo
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nav: Navigator
    @StateObject private var viewModel = HomeViewModel()
    
    let columns = [GridItem(.flexible(), spacing: 16),
                   GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.collections) { item in
                    CastleCollectionCell(props: CastleCollectionCellProps(item: item, onTap: {
                        
                    }))
                }
            }
            .padding(16)
        }
        .navigationTitle("名城を見つける")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.help) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
    }
}
