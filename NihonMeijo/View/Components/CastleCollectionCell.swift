//
//  CastleCollectionCell.swift
//  NihonMeijo
//

import SwiftUI

struct CastleCollectionCellProps {
    let item: CollectionModel
    let onTap: () -> Void
}

struct CastleCollectionCell: View {
    let props: CastleCollectionCellProps
    
    private let cellHeight: CGFloat = 120
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        Button(action: props.onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 8) {
                    Image(props.item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                Text(props.item.title)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(16)
            .frame(height: cellHeight)
            .cardStyle(cornerRadius: cornerRadius)
        }
    }
}
