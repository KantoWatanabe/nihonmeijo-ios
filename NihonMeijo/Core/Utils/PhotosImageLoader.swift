//
//  PhotosImageLoader.swift
//  NihonMeijo
//

import Photos
import UIKit

enum PhotoLibraryError: Error { case assetNotFound, unauthorized }

struct PhotosImageLoader {
    static func ensureReadAuth() async throws {
        let s = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if s == .authorized || s == .limited { return }
        if s == .notDetermined {
            let new = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if new == .authorized || new == .limited { return }
        }
        throw PhotoLibraryError.unauthorized
    }

    static func loadImage(localIdentifier: String,
                          targetSize: CGSize = CGSize(width: 1200, height: 1200),
                          contentMode: PHImageContentMode = .aspectFit) async throws -> UIImage {
        try await ensureReadAuth()

        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = result.firstObject else { throw PhotoLibraryError.assetNotFound }

        return try await withCheckedThrowingContinuation { cont in
            let opts = PHImageRequestOptions()
            opts.isSynchronous = false
            opts.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: contentMode,
                                                  options: opts) { image, _ in
                if let img = image { cont.resume(returning: img) }
                else { cont.resume(throwing: PhotoLibraryError.assetNotFound) }
            }
        }
    }

    /// 撮影した UIImage をフォトライブラリに保存し、その localIdentifier を返す
    static func saveToLibraryAndReturnLocalId(image: UIImage) async throws -> String {
        try await ensureReadAuth()
        return try await withCheckedThrowingContinuation { cont in
            var placeholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholder = req.placeholderForCreatedAsset
            }, completionHandler: { success, error in
                if let error = error { cont.resume(throwing: error); return }
                guard success, let localId = placeholder?.localIdentifier else {
                    cont.resume(throwing: PhotoLibraryError.assetNotFound); return
                }
                cont.resume(returning: localId)
            })
        }
    }
}
