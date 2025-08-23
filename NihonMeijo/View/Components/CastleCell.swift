//
//  CastleCell.swift
//  NihonMeijo
//

import SwiftUI

struct CastleCellProps {
    let item: CastleModel
    let onTap: () -> Void
}

struct CastleCell: View {
    let props: CastleCellProps
    
    private let cornerRadius: CGFloat = 14
    
    var body: some View {
        Button(action: props.onTap) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Image("Castle")
                    .resizable()
                    .scaledToFit()
                Spacer(minLength: 0)
                title
            }
            .aspectRatio(1, contentMode: .fit)
            .cardStyle(cornerRadius: cornerRadius)
        }
    }
    
    private var title: some View {
        Text(props.item.nameJa)
            .font(.headline)
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.65))
    }
}
