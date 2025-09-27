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
    var enableFullscreen: Bool = false

    @Environment(\.scenePhase) private var scenePhase
    @State private var image: UIImage?
    @State private var failed = false
    @State private var showOverlay = false
    @State private var isZoomed = false
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let img = image {
                if enableFullscreen {
                    imageContent(img)
                        .onTapGesture { showOverlay = true }
                } else {
                    imageContent(img)
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
            startLoading()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                loadTask?.cancel()
            }
        }
        .onDisappear {
            loadTask?.cancel()
        }
        .fullScreenCover(isPresented: $showOverlay) {
            if let img = image {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ZoomableImage(image: img, isZoomed: $isZoomed)
                        .onTapGesture {
                            if !isZoomed {
                                showOverlay = false
                            }
                        }
                }
                .gesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .local)
                        .onEnded { value in
                            let vertical = value.translation.height
                            let horizontal = abs(value.translation.width)
                            if !isZoomed && vertical > 100 && horizontal < 80 {
                                withAnimation {
                                    showOverlay = false
                                }
                            }
                        }
                )
            }
        }
    }

    private func startLoading() {
        failed = false
        image = nil
        loadTask?.cancel()

        loadTask = Task {
            do {
                try await PhotosImageLoader.ensureReadAuth()
                let img = try await PhotosImageLoader.loadImage(
                    localIdentifier: localIdentifier,
                    targetSize: targetSize,
                    contentMode: phContentMode
                )
                if Task.isCancelled { return }
                image = img
            } catch {
                if Task.isCancelled { return }
                failed = true
            }
        }
    }

    @ViewBuilder
    private func imageContent(_ img: UIImage) -> some View {
        if scaleMode == .fill {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
        }
    }
}

struct ZoomableImage: View {
    let image: UIImage
    @Binding var isZoomed: Bool

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let viewSize = geo.size

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: viewSize.width, height: viewSize.height)
                // ピンチで拡大縮小
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = clamp(lastScale * value, minScale, maxScale)
                            offset = clampedOffset(offset, in: viewSize)
                            isZoomed = scale > 1.0
                        }
                        .onEnded { _ in
                            lastScale = scale
                            offset = clampedOffset(offset, in: viewSize)
                            lastOffset = offset
                            isZoomed = scale > 1.0
                        }
                )
                // ドラッグで移動（拡大時のみ有効）
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard scale > 1.0 else { return }
                            offset = clampedOffset(
                                CGSize(width: lastOffset.width + value.translation.width,
                                       height: lastOffset.height + value.translation.height),
                                in: viewSize
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                // ダブルタップで 1x ↔︎ 2x トグル
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut) {
                        if scale > 1.0 {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                            isZoomed = false
                        } else {
                            scale = 2.0
                            lastScale = 2.0
                            offset = .zero
                            lastOffset = .zero
                            isZoomed = true
                        }
                    }
                }
        }
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(v, lo), hi)
    }

    // 画像は scaledToFit なので、実表示サイズを推定し、その範囲内にオフセットを制限
    private func clampedOffset(_ current: CGSize, in container: CGSize) -> CGSize {
        // 画像の素のサイズ
        let imgW = image.size.width
        let imgH = image.size.height
        guard imgW > 0, imgH > 0 else { return .zero }

        // コンテナ内での「scaledToFit」時のフィットサイズ
        let scaleToFit = min(container.width / imgW, container.height / imgH)
        let fittedW = imgW * scaleToFit * scale
        let fittedH = imgH * scaleToFit * scale

        // はみ出し許容量（左右/上下にどれだけ動かせるか）
        let maxX = max(0, (fittedW - container.width) / 2)
        let maxY = max(0, (fittedH - container.height) / 2)

        let clampedX = clamp(current.width, -maxX, maxX)
        let clampedY = clamp(current.height, -maxY, maxY)
        return CGSize(width: clampedX, height: clampedY)
    }
}
