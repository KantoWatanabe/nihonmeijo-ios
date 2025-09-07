//
//  UserCollectionEditorView.swift
//  NihonMeijo
//

import SwiftUI

struct UserCollectionEditorView: View {
    let editing: CollectionModel?

    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @Environment(\.dismiss) private var dismiss

    @State private var vm: UserCollectionListViewModel
    @State private var title: String = ""
    @State private var showDeleteAlert = false

    @FocusState private var focusedField: Bool

    private let rowHeight: CGFloat = 32

    init(editing: CollectionModel? = nil) {
        self.editing = editing
        _vm = State(initialValue: UserCollectionListViewModel())
        if let e = editing {
            _title = State(initialValue: e.title)
        }
    }

    var body: some View {
        VStack {
            titleInputArea
            
            if self.editing != nil {
                castleButton
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(editing == nil ? "コレクションを追加" : "コレクションを編集")
        .toolbar {
            if let e = editing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .alert("コレクションを削除しますか？", isPresented: $showDeleteAlert) {
                        Button("削除", role: .destructive) {
                            Task { @MainActor in
                                await mainVM.runAsync {
                                    try await vm.deleteAsync(item: e)
                                }
                                dismiss()
                            }
                        }
                        Button("キャンセル", role: .cancel) { }
                    } message: {
                        Text("コレクションに含まれるお城も削除されます。")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { @MainActor in
                        await mainVM.runAsync {
                            if let e = editing {
                                try await vm.updateAsync(item: e, title: title)
                            } else {
                                try await vm.createAsync(title: title)
                            }
                        }
                        dismiss()
                    }
                }
                label: {
                    Image(systemName: "checkmark")
                }
                .disabled(title.isBlank)
            }
        }
    }
    
    var titleInputArea: some View {
        VStack {
            HStack {
                Text("タイトル")
                Spacer()
                Text(title)
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            TextField("タイトル", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("閉じる") { focusedField = false }
                    }
                }
            .frame(height: rowHeight)

            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var castleButton: some View {
        Button {
            if let e = editing {
                nav.push(.userCastleList(e))
            }
        } label: {
            HStack(spacing: 8) {
                Image("Castle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                Text("お城を管理する")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 32)
    }
}
