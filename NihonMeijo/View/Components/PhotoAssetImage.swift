//
//  PhotoAssetImage.swift
//  NihonMeijo
//

import SwiftUI
import Photos

enum PhotoScaleMode {
    case fit
    case fill
}

struct PhotoAssetImage: View {
    let localIdentifier: String
    var targetSize: CGSize = .init(width: 800, height: 800)
    var phContentMode: PHImageContentMode = .aspectFit
    var scaleMode: PhotoScaleMode = .fill

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let img = image {
                if scaleMode == .fill {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                }
            } else if failed {
                Color.gray.opacity(0.2)
                    .overlay(Image(systemName: "photo.slash").imageScale(.large).opacity(0.7))
            } else {
                Color.gray.opacity(0.1)
                    .overlay(ProgressView())
            }
        }
        .task(id: localIdentifier) {
            do {
                try await PhotosImageLoader.ensureReadAuth()
                image = try await PhotosImageLoader.loadImage(
                    localIdentifier: localIdentifier,
                    targetSize: targetSize,
                    contentMode: phContentMode
                )
            } catch {
                failed = true
            }
        }
    }
}
