//
//  HomeView.swift
//  NihonMeijo
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm = HomeViewModel()
    
    let columns = [GridItem(.flexible(), spacing: 16),
                   GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.collections) { item in
                    CastleCollectionCell(props: CastleCollectionCellProps(item: item, onTap: {
                        nav.push(.castleList(item))
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
        .task {
            await mainVM.runAsync {
                try mainVM.syncIfNeededOnce()
                vm.load()
            }
        }
        .refreshable {
            await mainVM.runAsync {
                vm.load()
            }
        }
    }
}
