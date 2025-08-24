//
//  CastleDetailViewModel.swift
//  NihonMeijo
//

import Foundation
import Observation

@MainActor
@Observable
final class CastleDetailViewModel {
    let castle: CastleModel
    private let repo: CastleRepository

    var primaryPhotoLocalId: String?
    var isCleared: Bool = false
    var clearedAt: Date?
    var rating: Int?
    var clearedCostYen: Int?

    init(castle: CastleModel) {
        self.castle = castle
        self.repo = CastleRepository(context: StorageProvider.shared.context)
    }
    
    func load() throws {
        guard let e = repo.find(by: castle.id) else { return }
        isCleared = e.isCleared
        primaryPhotoLocalId = e.primaryPhotoLocalId
        clearedAt = e.clearedAt
        rating = e.rating
        clearedCostYen = e.clearedCostYen
    }
    
    func requestPhotoLibraryAccess() async throws {
        try await PhotosImageLoader.ensureReadAuth()
    }
    func setPrimaryPhoto(localId: String?) throws {
        try repo.setPrimaryPhotoLocalId(castle.id, to: localId)
        primaryPhotoLocalId = localId
    }
    func setPrimaryPhotoAsync(localId: String?) async throws {
        try await withCheckedThrowingContinuation { cont in
            do {
                try self.setPrimaryPhoto(localId: localId)
                cont.resume()
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
    
    func setCleared(_ newValue: Bool) throws {
        try repo.setCleared(castle.id, to: newValue)
        isCleared = newValue
    }
    func setClearedAsync(_ newValue: Bool) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try self.setCleared(newValue); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
    func toggleCleared() throws {
        try setCleared(!isCleared)
    }
    func toggleClearedAsync() async throws {
        try await setClearedAsync(!isCleared)
    }
    
    func setClearedDate(_ date: Date?) throws {
        try repo.setClearedDate(castle.id, date: date)
        clearedAt = date
    }
    func setClearedDateAsync(_ date: Date?) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try setClearedDate(date); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
    
    func setRating(_ value: Int?) throws {
        try repo.setRating(castle.id, to: value)
        rating = value
    }
    func setRatingAsync(_ value: Int?) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try setRating(value); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
    
    func setClearedCost(_ yen: Int?) throws {
        try repo.setClearedCost(castle.id, yen: yen)
        clearedCostYen = yen
    }
    func setClearedCostAsync(_ yen: Int?) async throws {
        try await withCheckedThrowingContinuation { cont in
            do { try setClearedCost(yen); cont.resume() }
            catch { cont.resume(throwing: error) }
        }
    }
}
