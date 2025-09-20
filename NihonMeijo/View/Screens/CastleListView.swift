//
//  CastleListView.swift
//  NihonMeijo
//

import SwiftUI

enum CastleLayout: String {
    case grid
    case list
}

enum SearchCategory: String, CaseIterable, Identifiable {
    case all = "すべて"
    case uncleared = "未攻略"
    case cleared = "攻略済み"
    var id: Self { self }
}

struct CastleListView: View {
    let collection: CollectionModel
    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: CastleListViewModel
    @State private var searchText: String = ""
    @State private var appliedQuery: String = ""
    @State private var showProgressPopover = false
    @State private var searchCategory: SearchCategory = .all

    @AppStorage("castle.layout") private var layout: CastleLayout = .grid

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    private func onlyClearedFlag(_ cat: SearchCategory) -> Bool? {
        switch cat {
        case .all: return nil
        case .uncleared: return false
        case .cleared: return true
        }
    }

    init(collection: CollectionModel) {
        self.collection = collection
        _vm = State(initialValue: CastleListViewModel(collection: collection))
    }
    
    var body: some View {
        let items: [CastleModel] = {
            let flag = onlyClearedFlag(searchCategory)
            let q = appliedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            if q.isEmpty {
                return vm.matchedCastles(for: "", limit: nil, onlyCleared: flag)
            } else {
                return vm.matchedCastles(for: q, limit: nil, onlyCleared: flag)
            }
        }()

        Group {
            if items.isEmpty {
                ContentUnavailableView {
                    Label("お城が見つかりません", image: "Castle")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 32)
            } else {
                if layout == .grid {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(items) { item in
                                CastleCell(props: CastleCellProps(item: item, onTap: {
                                    nav.push(.castleDetail(item))
                                }))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                } else {
                    List(items) { item in
                        CastleListCell(props: CastleListCellProps(item: item, onTap: {
                            nav.push(.castleDetail(item))
                        }))
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle(collection.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                progressButton
                    //.padding(.trailing, -16) // ToolbarItem間の余白を詰める
            }
            ToolbarItem(placement: .topBarTrailing) {
                castleLayoutButton
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "名称、都道府県で検索",
        )
        .searchScopes($searchCategory) {
            ForEach(SearchCategory.allCases) { cat in
                Text(cat.rawValue).tag(cat)
            }
        }
        .onSubmit(of: .search) {
            appliedQuery = searchText
        }
        .onChange(of: searchText) {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                appliedQuery = ""
            }
        }
        .searchSuggestions {
            SuggestionsView(
                vm: vm,
                searchText: searchText,
                onlyCleared: onlyClearedFlag(searchCategory)
            )
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
    
    private var progressButton: some View {
        Button {
            showProgressPopover.toggle()
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "flag.circle.fill")
                Text("\(vm.clearedPercent)%")
            }
        }
        .popover(isPresented: $showProgressPopover) {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(vm.totalCount)城中 \(vm.clearedCount)城 攻略")
                    .font(.body)

                if vm.totalCount > 0 {
                    ProgressView(value: Double(vm.clearedCount), total: Double(vm.totalCount))
                        .frame(maxWidth: 220)
                }
            }
            .padding()
            .presentationCompactAdaptation(PresentationAdaptation.popover)
        }
    }
    
    private var castleLayoutButton: some View {
        Button {
            layout = (layout == .grid) ? .list : .grid
        } label: {
            Image(systemName: layout == .grid ? "list.bullet" : "square.grid.2x2")
        }
    }
}

private struct SuggestionsView: View {
    @EnvironmentObject var nav: Navigator
    let vm: CastleListViewModel
    let searchText: String
    let onlyCleared: Bool?

    var body: some View {
        let results = vm.matchedCastles(for: searchText, limit: 10, onlyCleared: onlyCleared)
        if results.isEmpty {
            Text("検索結果がありません")
                .foregroundStyle(.secondary)
        } else {
            ForEach(results, id: \.id) { c in
                CastleListCell(props: CastleListCellProps(item: c, onTap: {
                    nav.push(.castleDetail(c))
                }))
                .foregroundStyle(.primary)
                //.searchCompletion(c.nameJa)
            }
        }
    }
}
