//
//  Navigator.swift
//  NihonMeijo
//

import SwiftUI

protocol Navigating: AnyObject {
    var path: NavigationPath { get set }
    func push(_ dest: AppRoute)
    func pop()
    func popToRoot()
    func replaceStack(with stack: [AppRoute])
}

final class Navigator: ObservableObject, Navigating {
    @Published var path = NavigationPath()
    
    func push(_ dest: AppRoute) {
        path.append(dest)
    }
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    func popToRoot() {
        path = NavigationPath()
    }
    func replaceStack(with stack: [AppRoute]) {
        path = NavigationPath(stack)
    }
}
