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

            myCollectionButton

            if vm.userCollections.isEmpty {
                Text("あなただけの名城がここに表示されます")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.userCollections) { item in
                        CastleCollectionCell(props: CastleCollectionCellProps(item: item, onTap: {
                            nav.push(.castleList(item))
                        }))
                    }
                }
            }
        }
        .padding(16)
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
                try vm.load()
            }
        }
        .refreshable {
            await mainVM.runAsync {
                try vm.load()
            }
        }
    }

    var myCollectionButton: some View {
        Button {
            nav.push(.userCollectionList)
        } label: {
            HStack {
                Text("あなただけの名城を集めよう")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 64)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("LaunchScreenBackground"))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 16)
    }
}
