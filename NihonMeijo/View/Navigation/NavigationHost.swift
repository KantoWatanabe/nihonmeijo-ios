//
//  NavigationHost.swift
//  NihonMeijo
//

import SwiftUI

struct NavigationHost: View {
    let initial: AppRoute
    
    @StateObject private var nav = Navigator()
    
    var body: some View {
        NavigationStack(path: $nav.path) {
            initial.makeView()
                .navigationDestination(for: AppRoute.self) { destination in
                    destination.makeView()
                }
        }
        .environmentObject(nav)
    }
}
