//
//  CardStyle.swift
//  NihonMeijo
//

import SwiftUI

extension View {
    func cardStyle(cornerRadius: CGFloat = 16) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .clipShape(shape)
            .background(
                shape
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color(.separator), lineWidth: 0.5)
            )
            .contentShape(shape)
    }
}
