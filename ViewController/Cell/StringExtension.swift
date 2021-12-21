//
//  StringExtension.swift
//  Git-it
//
//  Created by 박윤배 on 2021/06/01.
//

import Foundation

extension String {
    func hasCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z_]$", options: .caseInsensitive)
            if nil != regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: self.count)) {
                return true
            }
        } catch {
            return false
        }
        return false
    }
}
