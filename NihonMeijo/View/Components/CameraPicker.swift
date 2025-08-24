//
//  CameraPicker.swift
//  NihonMeijo
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onPicked: (String) -> Void  // localIdentifier をコールバック

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = context.coordinator
        return vc
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onPicked: onPicked)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let dismiss: DismissAction
        let onPicked: (String) -> Void

        init(dismiss: DismissAction, onPicked: @escaping (String) -> Void) {
            self.dismiss = dismiss
            self.onPicked = onPicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer { dismiss() }
            if let img = info[.originalImage] as? UIImage {
                Task {
                    // 撮影画像をライブラリへ保存し localIdentifier を得る
                    if let localId = try? await PhotosImageLoader.saveToLibraryAndReturnLocalId(image: img) {
                        onPicked(localId)
                    }
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
