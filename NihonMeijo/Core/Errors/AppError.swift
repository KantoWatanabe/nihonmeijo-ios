//
//  AppError.swift
//  NihonMeijo
//

import Foundation

public struct AppError: Error, LocalizedError, Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case notFound
        case conflict
        case invalidData
        case syncFailed
        case io
        case unknown
    }

    public let kind: Kind
    public let message: String
    public let cause: Error?

    public init(kind: Kind, message: String, cause: Error? = nil) {
        self.kind = kind
        self.message = message
        self.cause = cause
    }

    public var errorDescription: String? { message }
    
    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.kind == rhs.kind && lhs.message == rhs.message
    }
}

extension AppError {
    static func notFound(_ what: String, id: String) -> AppError {
        .init(kind: .notFound, message: "\(what)（id=\(id)）が見つかりません")
    }
    static func conflict(_ what: String, key: String) -> AppError {
        .init(kind: .conflict, message: "\(what) の一意制約に違反しました（\(key)）")
    }
    static func invalid(_ msg: String) -> AppError {
        .init(kind: .invalidData, message: msg)
    }
    static func sync(_ msg: String) -> AppError {
        .init(kind: .syncFailed, message: msg)
    }
    static func wrap(_ error: Error, fallback msg: String = "不明なエラーです") -> AppError {
        if let app = error as? AppError { return app }
        return .init(kind: .unknown, message: msg, cause: error)
    }
}
