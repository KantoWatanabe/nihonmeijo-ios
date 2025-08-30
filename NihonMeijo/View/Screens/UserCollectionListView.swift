//
//  UserCollectionListView.swift
//  NihonMeijo
//

import SwiftUI

struct UserCollectionListView: View {
    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: UserCollectionListViewModel

    init() {
        _vm = State(initialValue: UserCollectionListViewModel())
    }

    var body: some View {
        content
            .navigationTitle("あなたのコレクション")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        nav.push(.userCollectionEditor(nil))
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
        if vm.userCollections.isEmpty {
            VStack {
                Spacer()
                Text("コレクションがありません")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(vm.userCollections, id: \.id) { collection in
                    UserCollectionCell(props: UserCollectionCellProps(item: collection, onTap: {
                        nav.push(.userCollectionEditor(collection))
                    }))
                    .contentShape(Rectangle())
                }
                .onMove(perform: moveRows)
            }
            .listStyle(.plain)
        }
    }
    
    private func moveRows(from: IndexSet, to: Int) {
        vm.userCollections.move(fromOffsets: from, toOffset: to)
        Task { @MainActor in
            await mainVM.runAsync {
                try await vm.applyOrderingUserCreatedAsync()
            }
        }
    }
}
