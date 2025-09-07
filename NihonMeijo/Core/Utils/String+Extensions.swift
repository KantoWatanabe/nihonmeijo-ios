//
//  String+Extensions.swift
//  NihonMeijo
//

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
