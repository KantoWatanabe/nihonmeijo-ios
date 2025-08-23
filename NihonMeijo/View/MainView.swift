//
//  MainView.swift
//  NihonMeijo
//

import SwiftUI

struct MainView: View {
    @State private var mainVM = MainViewModel()

    var body: some View {
        ZStack {
            NavigationHost(initial: .home)
                .environment(mainVM)

            if mainVM.isLoading {
                LoadingOverlay(text: "同期中…").transition(.opacity)
            }

            if let msg = mainVM.errorMessage {
                ErrorBanner(message: msg) { mainVM.clearError() }.transition(.opacity)
            }
        }

    }
}

private struct LoadingOverlay: View {
    let text: String
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 8)
    }
}

private struct ErrorBanner: View {
    let message: String
    var onDismiss: () -> Void = {}
    @State private var isVisible = true

    var body: some View {
        if isVisible {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                Text(message)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                Button("閉じる") {
                    withAnimation { isVisible = false; onDismiss() }
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 8)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    guard isVisible else { return }
                    withAnimation { isVisible = false; onDismiss() }
                }
            }
        }
    }
}
