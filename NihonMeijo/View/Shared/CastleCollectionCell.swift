//
//  CastleCollectionCell.swift
//  NihonMeijo
//

import SwiftUI

struct CastleCollectionCellProps {
    let item: CastleCollectionModel
    let onTap: () -> Void
}

struct CastleCollectionCell: View {
    let props: CastleCollectionCellProps
    
    private let cellHeight: CGFloat = 120
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        Button(action: props.onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color(.separator), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
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
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
            }
            .frame(height: cellHeight)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
