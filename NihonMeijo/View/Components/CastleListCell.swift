//
//  CastleListCell.swift
//  NihonMeijo
//

import SwiftUI

struct CastleListCellProps {
    let item: CastleModel
    let onTap: () -> Void
}

struct CastleListCell: View {
    let props: CastleListCellProps

    var body: some View {
        Button(action: props.onTap) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(props.item.nameJa)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Text(props.item.prefecture.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if let date = props.item.clearedAt {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(" ")
                            .font(.caption)
                    }
                    
                    if let cost = props.item.clearedCostYen {
                        Text("\(cost, format: .number.grouping(.automatic)) 円")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(" ")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: props.item.rating != nil ? "star.fill" :"star")
                        .foregroundColor(.orange)
                        .frame(width: 28, height: 28)

                    Text(props.item.rating.map { "\($0)" } ?? "-")
                        .font(.subheadline)
                }
                
                ZStack {
                    Circle()
                        .fill(props.item.isCleared ? Color.green : Color.gray)
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(6)
            }
        }
    }
}
