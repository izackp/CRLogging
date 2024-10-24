//
//  Encodable+Logs.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

extension Encodable {
    public func expectOrLog<T>(_ block:()->T?) -> T? {
        return CRLogging.expectOrLog(self, block)
    }

    public func tryOrLog<T>(_ block:() throws ->T) -> T? {
        return CRLogging.tryOrLog(self, block)
    }

    public func tryOrLog<T>(info:String, _ block:() throws ->T) -> T? {
        return CRLogging.tryOrLog(self, info:info, block)
    }

    public func tryOrLogInput<T, R>(_ info:R, _ block:(_ input:R) throws ->T) -> T? {
        return CRLogging.tryOrLogInput(self, info, block)
    }

    public func logAndReportException(_ error:Error, _ info:String? = nil) {
        CRLogging.logAndReportException(self, error, info)
    }

    public func logAndReportError(_ error:String) {
        CRLogging.logAndReportError(self, error)
    }

    public func logNil(_ info: String? = nil) {
        CRLogging.logNil(self, info)
    }
}
