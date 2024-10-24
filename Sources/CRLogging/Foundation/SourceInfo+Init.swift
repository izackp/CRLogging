//
//  SourceInfo+Init.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

import Foundation

public extension SourceInfo {
    init(type: String) {
        self.instanceId = 0
        self.type = URL(fileURLWithPath: type).lastPathComponent
    }
}
