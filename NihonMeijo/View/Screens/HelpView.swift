//
//  HelpView.swift
//  NihonMeijo
//

import SwiftUI

struct HelpView: View {
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text(ResourceLoader.appVersion)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("ヘルプ")
    }
}
