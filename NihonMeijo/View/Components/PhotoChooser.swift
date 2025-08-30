//
//  PhotoChooser.swift
//  NihonMeijo
//

import SwiftUI
import PhotosUI

struct PhotoChooser: View {
    @Binding var photoLocalId: String?

    var onRequireLibraryAccess: () async throws -> Void
    var onSetLocalId: (_ localId: String?) async throws -> Void
    var allowsCamera: Bool = true

    @State private var showSourceDialog = false
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        Group {
            ZStack(alignment: .topTrailing) {
                if let localId = photoLocalId {
                    PhotoAssetImage(localIdentifier: localId)
                        .padding(8)

                    Button {
                        Task {
                            try? await onSetLocalId(nil)
                            photoLocalId = nil
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
            .padding(.horizontal, 24)
        }
        .confirmationDialog("写真の追加方法を選択", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("写真ライブラリから選ぶ") {
                Task {
                    try? await onRequireLibraryAccess()
                    showLibraryPicker = true
                }
            }
            if allowsCamera {
                Button("写真を撮影する") { showCameraPicker = true }
            }
            Button("キャンセル", role: .cancel) { }
        }
        .photosPicker(isPresented: $showLibraryPicker, selection: $photoItem, matching: .images, photoLibrary: .shared())
        .task(id: photoItem) {
            guard let item = photoItem,
                  let localId = item.itemIdentifier else { return }
            Task {
                try? await onSetLocalId(localId)
                photoLocalId = localId
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker { localId in
                Task {
                    try? await onSetLocalId(localId)
                    photoLocalId = localId
                }
            }
            .ignoresSafeArea()
        }
    }
}
