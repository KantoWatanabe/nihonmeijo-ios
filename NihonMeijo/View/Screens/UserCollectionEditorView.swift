//
//  UserCollectionEditorView.swift
//  NihonMeijo
//

import SwiftUI

struct UserCollectionEditorView: View {
    let editing: CollectionModel?

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
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        }
        .padding(.horizontal, 8)
    }
}
