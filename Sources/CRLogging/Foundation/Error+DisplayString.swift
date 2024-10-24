//
//  Error+DisplayString.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

import Foundation

public extension Error {
    func displayString() -> String {
        if let myErr = self as? LocalizedError {
            return myErr.localizedDescription
        }
        return String(describing: self)
    }
}
