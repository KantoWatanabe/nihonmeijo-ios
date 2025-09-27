//
//  CameraPicker.swift
//  NihonMeijo
//

import SwiftUI
import PhotosUI

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
        private var saveTask: Task<Void, Never>?

        init(dismiss: DismissAction, onPicked: @escaping (String) -> Void) {
            self.dismiss = dismiss
            self.onPicked = onPicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer { dismiss() }
            if let img = info[.originalImage] as? UIImage {
                saveTask?.cancel()

                saveTask = Task {
                    do {
                        let localId = try await PhotosImageLoader.saveToLibraryAndReturnLocalId(image: img)
                        if Task.isCancelled { return }
                        onPicked(localId)
                    } catch {
                        print("❌ Failed to save image to library: \(error)")
                    }
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            saveTask?.cancel()
            dismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
