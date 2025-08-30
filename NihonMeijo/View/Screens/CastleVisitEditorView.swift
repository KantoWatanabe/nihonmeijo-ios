//
//  CastleVisitEditorView.swift
//  NihonMeijo
//

import SwiftUI
import PhotosUI

struct CastleVisitEditorView: View {
    let castle: CastleModel
    let editing: CastleVisitModel?

    @Environment(MainViewModel.self) private var mainVM
    @Environment(\.dismiss) private var dismiss

    @State private var vm: CastleVisitListViewModel
    @State private var text: String = ""
    @State private var photoLocalId: String?

    @FocusState private var focusedField: Bool

    init(castle: CastleModel, editing: CastleVisitModel? = nil) {
        self.castle = castle
        self.editing = editing
        _vm = State(initialValue: CastleVisitListViewModel(castle: castle))
        if let e = editing {
            _text = State(initialValue: e.text)
            _photoLocalId = State(initialValue: e.photoLocalId)
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                TextEditor(text: $text)
                    .focused($focusedField)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("閉じる") { focusedField = false }
                        }
                    }
                PhotoChooser(
                    photoLocalId: $photoLocalId,
                    onRequireLibraryAccess: {
                        await mainVM.runAsync {
                            try await PhotosImageLoader.ensureReadAuth()
                        }
                    },
                    onSetLocalId: { id in
                        // NOP
                    },
                    allowsCamera: true,
                )
            }
            .padding()
        }
        .navigationTitle(editing == nil ? "記録を追加" : "記録を編集")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { @MainActor in
                        await mainVM.runAsync {
                            if let e = editing {
                                try vm.update(item: e, text: text, photoLocalId: photoLocalId)
                            } else {
                                try vm.create(text: text, photoLocalId: photoLocalId)
                            }
                        }
                        dismiss()
                    }
                }
                label: {
                    Image(systemName: "checkmark")
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && photoLocalId == nil)
            }
        }
    }
}
