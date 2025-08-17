//
//  ResourceLoader.swift
//  NihonMeijo
//

import Foundation

private protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
extension JSONDecoder: DataDecoder {}
extension PropertyListDecoder: DataDecoder {}

enum ResourceLoader {
    
    static func getInfoPlistValue<T>(forKey key: String) -> T {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
            fatalError("\(key) is missing or not of type \(T.self) in Info.plist")
        }
        return value
    }
    
    static var appVersion: String {
        return getInfoPlistValue(forKey: "CFBundleShortVersionString")
    }
    
    static var buildNumber: String {
        return getInfoPlistValue(forKey: "CFBundleVersion")
    }
    
    static var appName: String {
        return getInfoPlistValue(forKey: "CFBundleDisplayName")
    }
    
    static func loadPlist<T: Decodable>(named fileName: String, bundle: Bundle = .main) -> T {
        let decoder = PropertyListDecoder()
        return load(named: fileName, withExtension: "plist", in: bundle, decoder: decoder)
    }
    
    static func loadJSON<T: Decodable>(named fileName: String, bundle: Bundle = .main) -> T {
        let decoder = JSONDecoder()
        return load(named: fileName, withExtension: "json", in: bundle, decoder: decoder)
    }
    
    private static func load<T: Decodable, D: DataDecoder>(named fileName: String, withExtension ext: String, in bundle: Bundle = .main, decoder: D) -> T {
        guard let url = bundle.url(forResource: fileName, withExtension: ext) else {
            fatalError("Missing resource: \(fileName).\(ext)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(fileName).\(ext): \(error)")
        }
    }
}
