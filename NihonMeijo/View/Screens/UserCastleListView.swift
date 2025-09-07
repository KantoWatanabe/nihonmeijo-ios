//
//  UserCastleListView.swift
//  NihonMeijo
//

import SwiftUI

struct UserCastleListView: View {
    let collection: CollectionModel

    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: UserCastleListViewModel

    let columns = [GridItem(.flexible(), spacing: 16),
                   GridItem(.flexible(), spacing: 16)]

    init(collection: CollectionModel) {
        self.collection = collection
        _vm = State(initialValue: UserCastleListViewModel(collection: collection))
    }

    var body: some View {
        content
            .navigationTitle("あなたのお城")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        nav.push(.userCastleEditor(collection, nil))
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await mainVM.runAsync {
                    try vm.load()
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        if vm.userCastles.isEmpty {
            VStack {
                Spacer()
                Text("お城がありません")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.userCastles) { item in
                        CastleCell(props: CastleCellProps(item: item, onTap: {
                            nav.push(.userCastleEditor(collection, item))
                        }))
                    }
                }
            }
            .padding(16)
        }
    }
}
