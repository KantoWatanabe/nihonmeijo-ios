//
//  MainViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@Observable
final class MainViewModel {
    // UI 状態
    private var loadingCount = 0
    var errorMessage: String?
    var didRunInitialSync = false

    var isLoading: Bool { loadingCount > 0 }

    // MARK: - UIユーティリティ
    @MainActor func startLoading() { loadingCount += 1 }
    @MainActor func stopLoading()  { loadingCount = max(loadingCount - 1, 0) }
    @MainActor func setError(_ error: Error) {
        if let app = error as? AppError { errorMessage = app.message }
        else { errorMessage = error.localizedDescription }
    }
    @MainActor func clearError() { errorMessage = nil }

    /// 任意の処理をローディング＆エラーハンドリング付きで実行
    @MainActor
    func run(_ work: @escaping () throws -> Void) {
        startLoading()
        defer { stopLoading() }
        do { try work() } catch { setError(error) }
    }

    /// 非同期版
    @MainActor
    func runAsync(_ work: @escaping () async throws -> Void) async {
        startLoading()
        defer { stopLoading() }
        do { try await work() } catch { setError(error) }
    }

    // MARK: - 起動時のマスタ同期（1回だけ）
    @MainActor
    func syncIfNeededOnce() throws {
        guard didRunInitialSync == false else { return }
        didRunInitialSync = true
        try MasterSyncService.syncIfNeeded()
    }
}
