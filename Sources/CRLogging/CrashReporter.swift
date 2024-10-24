//
//  CrashReporter.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/22/24.
//

import Foundation

public struct CrashReporter {
    
    public static var reporter:ICrashReporter = EmptyCrashReporter()
    
    public static func capture(_ message:String, info:String? = nil) {
        reporter.capture(message, info: info)
    }
    
    public static func capture(_ error:Error, info:String? = nil) {
        if let exception = error as? NSException {
            reporter.capture(exception, info: info)
        } else {
            reporter.capture(error, info: info)
        }
    }
    
    public static func capture(_ exception:NSException, info:String? = nil) {
        reporter.capture(exception, info: info)
    }
    
    public static func writeToFile(_ message:String) {
        reporter.writeToFile(message)
    }
}

public protocol ICrashReporter {
    func capture(_ message:String, info:String?)
    func capture(_ error:Error, info:String?)
    func capture(_ exception:NSException, info:String?)
    func writeToFile(_ message:String)
}

public class EmptyCrashReporter: ICrashReporter {
    public func capture(_ message: String, info: String?) {}
    public func capture(_ error: Error, info: String?) {}
    public func capture(_ exception: NSException, info: String?) {}
    public func writeToFile(_ message:String) {}
}
