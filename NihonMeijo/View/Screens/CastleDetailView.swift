//
//  CastleDetailView.swift
//  NihonMeijo
//

import SwiftUI
import PhotosUI
import SwiftData

struct CastleDetailView: View {
    let castle: CastleModel
    @Environment(MainViewModel.self) private var mainVM
    @State private var vm: CastleDetailViewModel

    @Environment(\.openURL) private var openURL

    @State private var showSourceDialog = false
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var focusedField: Bool

    private let rowHeight: CGFloat = 32

    init(castle: CastleModel) {
        self.castle = castle
        _vm = State(initialValue: CastleDetailViewModel(castle: castle))
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                primaryPhotoArea

                InfoRow(label: "名称", value: castle.nameJa)
                InfoRow(label: "読み方", value: castle.nameKana)
                InfoRow(label: "所在地", value: castle.address)

                isClearedArea

                clearedAtArea

                ratingArea

                clearedCostYenArea
                
                webSearchArea
            }
        }
        .navigationTitle(castle.nameJa)
        .confirmationDialog("写真の追加方法を選択", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("写真ライブラリから選ぶ") {
                Task {
                    await mainVM.runAsync {
                        try await vm.requestPhotoLibraryAccess()
                        showLibraryPicker = true
                    }
                }
            }
            Button("写真を撮影する") { showCameraPicker = true }
            Button("キャンセル", role: .cancel) { }
        }
        .photosPicker(isPresented: $showLibraryPicker, selection: $photoItem, matching: .images, photoLibrary: .shared())
        .task(id: photoItem) {
            guard let item = photoItem,
                  let localId = item.itemIdentifier else { return }
            await mainVM.runAsync {
                try await vm.setPrimaryPhotoAsync(localId: localId)

            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker { localId in
                Task {
                    await mainVM.runAsync {
                        try await vm.setPrimaryPhotoAsync(localId: localId)
                    }
                }
            }
            .ignoresSafeArea()
        }
        .task {
            await mainVM.runAsync {
                try vm.load()
            }
        }
    }
    
    var primaryPhotoArea: some View {
        Group {
            ZStack(alignment: .topTrailing) {
                if let localIdentifier = vm.primaryPhotoLocalId {
                    PhotoAssetImage(localIdentifier: localIdentifier)
                        .padding(8)

                    Button {
                        Task {
                            await mainVM.runAsync { try await vm.setPrimaryPhotoAsync(localId: nil) }
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white, .red)
                            .font(.system(size: 32, weight: .bold))
                            .shadow(radius: 2)
                    }
                } else {
                    Button {
                        showSourceDialog = true
                    } label: {
                        Image("Castle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                }
            }
            .frame(maxWidth: 300)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)

            Button {
                showSourceDialog = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                    Text("写真を追加")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            Divider().padding(.horizontal, 8)
        }
    }
    
    func InfoRow(label: String, value: String) -> some View {
        Group {
            HStack {
                Text(label)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var isClearedArea: some View {
        Group {
            Toggle(isOn: Binding(
                get: { vm.isCleared },
                set: { newValue in
                    Task {
                        await mainVM.runAsync {
                            try await vm.setClearedAsync(newValue)
                        }
                    }
                }
            )) {
                HStack {
                    Text("攻略済み")
                    Image(systemName: vm.isCleared ? "checkmark.seal.fill" : "checkmark.seal")
                }
            }
            .toggleStyle(.switch)
            .frame(height: rowHeight)
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var clearedAtArea: some View {
        Group {
            HStack {
                if let d = vm.clearedAt {
                    DatePicker(
                        "攻略日",
                        selection: Binding(
                            get: { d },
                            set: { newDate in
                                Task { await mainVM.runAsync { try await vm.setClearedDateAsync(newDate) } }
                            }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)

                    Button {
                        Task { await mainVM.runAsync { try await vm.setClearedDateAsync(nil) } }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                } else {
                    HStack {
                        Text("攻略日")
                        Spacer()
                        Text("未設定")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { await mainVM.runAsync { try await vm.setClearedDateAsync(Date()) } }
                    }
                }
            }
            .frame(height: rowHeight)
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var ratingArea: some View {
        Group {
            HStack {
                Text("評価")
                Spacer()
                Text(vm.rating.map { "\($0)/5" } ?? "未設定")
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            Picker("評価", selection: Binding(
                get: { vm.rating ?? 0 },
                set: { newValue in
                    Task { await mainVM.runAsync { try await vm.setRatingAsync(newValue == 0 ? nil : newValue) } }
                }
            )) {
                Text("未選択").tag(0)
                ForEach(1...5, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .frame(height: rowHeight)
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var clearedCostYenArea: some View {
        Group {
            HStack {
                Text("攻略費用")
                Spacer()

                Text(vm.clearedCostYen.flatMap { yenFormatter().string(from: NSNumber(value: $0)) } ?? "未設定")
                    .foregroundStyle(.secondary)
            }
            .frame(height: rowHeight)

            HStack {
                TextField("金額（円）", text: Binding(
                    get: { vm.clearedCostYen.map(String.init) ?? "" },
                    set: { newValue in
                        let digits = newValue.filter(\.isNumber)
                        Task {
                            await mainVM.runAsync {
                                if digits.isEmpty {
                                    try await vm.setClearedCostAsync(nil)
                                } else if let v = Int(digits) {
                                    try await vm.setClearedCostAsync(v)
                                }
                            }
                        }
                    }
                ))
                .keyboardType(.numberPad)
                .focused($focusedField)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("閉じる") { focusedField = false }
                    }
                }

                if vm.clearedCostYen != nil {
                    Button {
                        Task { await mainVM.runAsync { try await vm.setClearedCostAsync(nil) } }
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            .accessibilityLabel("攻略費用を消去")
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: rowHeight)
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    var webSearchArea: some View {
        Group {
            if let url = webSearchURL(for: castle.nameJa) {
                Button {
                    openURL(url)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                        Text("Webで調べる")
                            .underline()
                    }
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: rowHeight)
            }
            Divider()
        }
        .padding(.horizontal, 8)
    }
    
    private func yenFormatter() -> NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ja_JP")
        nf.numberStyle = .currency
        nf.currencyCode = "JPY"
        nf.maximumFractionDigits = 0
        return nf
    }
    private func webSearchURL(for query: String) -> URL? {
        var comp = URLComponents(string: "https://www.google.com/search")
        comp?.queryItems = [
            URLQueryItem(name: "q",  value: query),
            URLQueryItem(name: "hl", value: "ja")
        ]
        return comp?.url
    }
}
