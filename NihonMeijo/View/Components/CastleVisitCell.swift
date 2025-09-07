//
//  CastleVisitCell.swift
//  NihonMeijo
//

import SwiftUI

struct CastleVisitCellProps {
    let item: CastleVisitModel
    let onTap: () -> Void
}

struct CastleVisitCell: View {
    let props: CastleVisitCellProps

    private var hasText: Bool {
        !props.item.text.isBlank
    }
    private var hasPhoto: Bool {
        props.item.photoLocalId != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if hasText {
                Text(props.item.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let localId = props.item.photoLocalId {
                HStack {
                    Spacer()
                    PhotoAssetImage(
                        localIdentifier: localId,
                        targetSize: .zero,
                        phContentMode: .aspectFit,
                        scaleMode: .fit,
                        enableFullscreen: true
                    )
                    .frame(height: 240)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
}
