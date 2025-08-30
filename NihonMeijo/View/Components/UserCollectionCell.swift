//
//  UserCollectionCell.swift
//  NihonMeijo
//

import SwiftUI

struct UserCollectionCellProps {
    let item: CollectionModel
    let onTap: () -> Void
}

struct UserCollectionCell: View {
    let props: UserCollectionCellProps

    var body: some View {
        Button(action: props.onTap) {
            HStack(spacing: 10) {
                Text(props.item.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
        }
    }
}
