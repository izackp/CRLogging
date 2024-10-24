//
//  MessageId.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

public enum MessageId : UInt16, Sendable {
    case trace
    case debug
    case info
    case warning
    case error
    case fatal
    case instanceInit
    case instanceDeint
}
