//
//  UserCastleEditorView.swift
//  NihonMeijo
//

import SwiftUI

struct UserCastleEditorView: View {
    let collection: CollectionModel
    let editing: CastleModel?

    @EnvironmentObject var nav: Navigator
    @Environment(MainViewModel.self) private var mainVM
    @Environment(\.dismiss) private var dismiss

    @State private var vm: UserCastleListViewModel
    @State private var nameJa: String = ""
    @State private var nameKana: String = ""
    @State private var address: String = ""
    @State private var prefCode: PrefCode = .hokkaido
    @State private var showDeleteAlert = false
    @State private var showPrefSheet = false

    @FocusState private var focusedField: Bool

    private let rowHeight: CGFloat = 32

    init(collection: CollectionModel, editing: CastleModel? = nil) {
        self.collection = collection
        self.editing = editing
        _vm = State(initialValue: UserCastleListViewModel(collection: collection))
        if let e = editing {
            _nameJa = State(initialValue: e.nameJa)
            _nameKana = State(initialValue: e.nameKana)
            _address = State(initialValue: e.address)
            _prefCode = State(initialValue: e.prefecture)
        }
    }

    var body: some View {
        VStack {
            nameJaInputArea

            nameKanaInputArea
            
            addressInputArea
            
            prefCodeSelectArea

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("閉じる") { focusedField = false }
            }
        }
        .navigationTitle(editing == nil ? "お城を追加" : "お城を編集")
        .toolbar {
            if let e = editing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .alert("お城を削除しますか？", isPresented: $showDeleteAlert) {
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
                        Text(e.nameJa)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { @MainActor in
                        await mainVM.runAsync {
                            if let e = editing {
                                try await vm.updateAsync(item: e, nameJa: nameJa, nameKana: nameKana, address: address, prefCode: prefCode)
                            } else {
                                try await vm.createAsync(nameJa: nameJa, nameKana: nameKana, address: address, prefCode: prefCode)
                            }
                        }
                        dismiss()
                    }
                }
                label: {
                    Image(systemName: "checkmark")
                }
                .disabled(isSaveDisabled)
            }
        }
        .sheet(isPresented: $showPrefSheet) {
            PrefSheet(isPresented: $showPrefSheet, selection: $prefCode)
        }
    }
    
    var nameJaInputArea: some View {
        VStack {
            HStack {
                Text("名称")
                Spacer()
                Text(nameJa)
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            TextField("名称", text: $nameJa)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField)
            .frame(height: rowHeight)

            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var nameKanaInputArea: some View {
        VStack {
            HStack {
                Text("読み方")
                Spacer()
                Text(nameKana)
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            TextField("読み方", text: $nameKana)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField)
            .frame(height: rowHeight)

            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var addressInputArea: some View {
        VStack {
            HStack {
                Text("所在地")
                Spacer()
                Text(address)
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            TextField("所在地", text: $address)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField)
            .frame(height: rowHeight)

            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var prefCodeSelectArea: some View {
        VStack {
            HStack {
                Text("都道府県")
                Spacer()
                Button(action: { showPrefSheet = true }) {
                    Text(prefCode.rawValue)
                }
            }
            .frame(height: rowHeight)

            //Divider()
        }
        .padding(.horizontal, 8)
    }
    
    private var isSaveDisabled: Bool {
        nameJa.isBlank || nameKana.isBlank || address.isBlank
    }
}

struct PrefSheet: View {
    @Binding var isPresented: Bool
    @Binding var selection: PrefCode

    @State private var tempSelection: PrefCode

    init(isPresented: Binding<Bool>, selection: Binding<PrefCode>) {
        _isPresented = isPresented
        _selection = selection
        _tempSelection = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        VStack {
            Button("決定") {
                selection = tempSelection
                isPresented = false
            }
            .bold()
            .frame(height: 44)

            Divider()

            Picker("都道府県", selection: $tempSelection) {
                ForEach(PrefCode.allCases, id: \.self) { pref in
                    Text(pref.rawValue).tag(pref)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
        .presentationDetents([.height(256)])
        .onChange(of: isPresented) {
            if isPresented {
                tempSelection = selection
            }
        }
    }
}
