//
//  CastleListView.swift
//  NihonMeijo
//

import SwiftUI

struct CastleListView: View {
    let collection: CollectionModel
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: CastleListViewModel
    
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    init(collection: CollectionModel) {
        self.collection = collection
        _vm = State(initialValue: CastleListViewModel(collection: collection))
    }
    
    var body: some View {
        ScrollView {
            if vm.castles.isEmpty {
                ContentUnavailableView {
                    Label("お城が見つかりません", image: "Castle")
                }
                    .padding(.top, 32)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vm.castles) { item in
                        CastleCell(props: CastleCellProps(item: item, onTap: {}))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle(collection.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.help) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .task {
            await mainVM.runAsync {
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
