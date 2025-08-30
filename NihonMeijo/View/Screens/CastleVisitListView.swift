//
//  CastleVisitListView.swift
//  NihonMeijo
//

import SwiftUI

struct CastleVisitListView: View {
    let castle: CastleModel
    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: CastleVisitListViewModel

    init(castle: CastleModel) {
        self.castle = castle
        _vm = State(initialValue: CastleVisitListViewModel(castle: castle))
    }

    var body: some View {
        content
            .navigationTitle("攻城記")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        nav.push(.castleVisitEditor(castle, nil))
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
        if vm.castleVisits.isEmpty {
            VStack {
                Spacer()
                Text("記録がありません")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(vm.castleVisits, id: \.id) { visit in
                    CastleVisitCell(props: CastleVisitCellProps(item: visit, onTap: {
                        // onTap
                    }))
                    .listRowInsets(.init(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { @MainActor in
                                await mainVM.runAsync {
                                    try await vm.deleteAsync(item: visit)
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        Button {
                            nav.push(.castleVisitEditor(castle, visit))
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .onMove(perform: moveRows)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 16)
        }
    }
    
    private func moveRows(from: IndexSet, to: Int) {
        vm.castleVisits.move(fromOffsets: from, toOffset: to)
        Task { @MainActor in
            await mainVM.runAsync {
                try await vm.applyOrderingAsync()
            }
        }
    }
}
