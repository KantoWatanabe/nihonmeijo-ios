//
//  CastleCell.swift
//  NihonMeijo
//

import SwiftUI

struct SquareBox<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        GeometryReader { g in
            content()
                .frame(width: g.size.width, height: g.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct CastleCellProps {
    let item: CastleModel
    let onTap: () -> Void
}

struct CastleCell: View {
    let props: CastleCellProps
    
    private let cornerRadius: CGFloat = 14
    
    var body: some View {
        Button(action: props.onTap) {
            ZStack(alignment: .bottom) {
                SquareBox {
                    if let localId = props.item.primaryPhotoLocalId, !localId.isEmpty {
                        PhotoAssetImage(localIdentifier: localId)
                    } else {
                        Image("Castle")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                Text(props.item.nameJa)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.65))
            }
            .overlay(alignment: .topTrailing) {
                if props.item.isCleared {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(6)
                }
            }
            .cardStyle()
        }
    }
}
