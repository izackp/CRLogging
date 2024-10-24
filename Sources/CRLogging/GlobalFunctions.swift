//
//  Logging.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/22/24.
//

//As of Swift 5.3 #file is now file name instead of filepath


public func expectOrLog<T>(_ instance:Any, _ block:()->T?) -> T? {
    let source = SourceInfo(instance: instance)
    return expectOrLog(source, block)
}

public func expectOrLog<T>(_ sourceInfo:SourceInfo, _ block:()->T?) -> T? {
    let result = block()
    if (result == nil) {
        logAndReportError(sourceInfo, "Expected value for variable.")
    }
    return result
}

//MARK: -
public func tryOrLog<T>(_ instance:Any, _ block:() throws ->T) -> T? {
    let source = SourceInfo(instance: instance)
    return tryOrLog(source, block)
}

public func tryOrLog<T>(_ sourceInfo:SourceInfo, _ block:() throws ->T) -> T? {
    do {
        let result = try block()
        return result
    } catch let error {
        logAndReportException(sourceInfo, error)
    }
    return nil
}

public func tryOrLog<T>(_ instance:Any, info:String, _ block:() throws ->T) -> T? {
    let source = SourceInfo(instance: instance)
    return tryOrLog(source, info:info, block)
}

public func tryOrLog<T>(_ sourceInfo:SourceInfo, info:String, _ block:() throws ->T) -> T? {
    do {
        let result = try block()
        return result
    } catch let error {
        logAndReportException(sourceInfo, error, info)
    }
    return nil
}

//MARK: -
public func tryOrLogInput<T, R>(_ instance:Any, _ info:R, _ block:(_ input:R) throws ->T) -> T? {
    do {
        let result = try block(info)
        return result
    } catch let error {
        logAndReportException(instance, error, String.init(describing: info))
    }
    return nil
}

public func tryOrLogInput<T, R>(_ sourceInfo:SourceInfo, _ info:R, _ block:(_ input:R) throws ->T) -> T? {
    do {
        let result = try block(info)
        return result
    } catch let error {
        logAndReportException(sourceInfo, error, String.init(describing: info))
    }
    return nil
}

//MARK: -
public func logMessage(_ instance:Any, _ messageId:MessageId, _ data:String? = nil) {
    let source = SourceInfo(instance: instance)
    let lm = LogMessage(source: source, messageId: messageId, data: data)
    writeToFile(lm.description)
}

public func logMessage(_ messageId:MessageId, _ data:String? = nil, file:String = #file) {
    let source = SourceInfo(type: file)
    let lm = LogMessage(source: source, messageId: messageId, data: data)
    writeToFile(lm.description)
}

public func logMessage(_ sourceInfo:SourceInfo, _ messageId:MessageId, _ data:String? = nil, _ info:String? = nil) {
    if let data = data, let info = info {
        let newMessage = "\(data) - \(info)"
        let lm = LogMessage(source: sourceInfo, messageId: messageId, data: newMessage)
        writeToFile(lm.description)
    } else {
        let lm = LogMessage(source: sourceInfo, messageId: messageId, data: data)
        writeToFile(lm.description)
    }
}

//MARK: -
public func logAndReportException(_ instance:Any, _ error:Error, _ info:String? = nil) {
    let source = SourceInfo(instance: instance)
    logAndReportException(source, error, info)
}

public func logAndReportException(_ error:Error, _ info:String? = nil, file:String = #file) {
    let source = SourceInfo(type: file)
    logAndReportException(source, error, info)
}

public func logAndReportException(_ sourceInfo:SourceInfo, _ error:Error, _ info:String? = nil) {
    CrashReporter.capture(error, info: info)
    let msg = "Handled Exception: \(error.displayString())"
    logMessage(sourceInfo, .error, msg, info)
}

//MARK: -
public func logAndReportError(_ instance:Any, _ error:String, _ info:String? = nil) {
    let source = SourceInfo(instance: instance)
    logAndReportError(source, error, info)
}

public func logAndReportError(_ error:String, _ info:String? = nil, file:String = #file) {
    let source = SourceInfo(type: file)
    logAndReportError(source, error, info)
}

public func logAndReportError(_ sourceInfo:SourceInfo, _ error:String, _ info:String? = nil) {
    let message = "Handled Error: \(error)"
    CrashReporter.capture(message)
    
    logMessage(sourceInfo, .error, message, info)
}

//MARK: -
public func logAndReportFatalException(_ instance:Any, _ error:Error, _ info:String? = nil) {
    let source = SourceInfo(instance: instance)
    logAndReportFatalException(source, error, info)
}

public func logAndReportFatalException(_ error:Error, _ info:String? = nil, file:String = #file) {
    let source = SourceInfo(type: file)
    logAndReportFatalException(source, error, info)
}

public func logAndReportFatalException(_ sourceInfo:SourceInfo, _ error:Error, _ info:String? = nil) {
    CrashReporter.capture(error, info: info)
    
    let msg = "Fatal Exception: \(String(describing:error))"
    logMessage(sourceInfo, .fatal, msg, info)
}

//MARK: -
public func logAndReportFatalError(_ instance:Any, _ error:String, _ info:String? = nil) {
    let source = SourceInfo(instance: instance)
    logAndReportFatalError(source, error, info)
}

public func logAndReportFatalError(_ error:String, _ info:String? = nil, file:String = #file) {
    let source = SourceInfo(type: file)
    logAndReportFatalError(source, error, info)
}

public func logAndReportFatalError(_ sourceInfo:SourceInfo, _ error:String, _ info:String? = nil) {
    let message = "Fatal Error: \(error)"
    CrashReporter.capture(message, info: info)
    
    logMessage(sourceInfo, .fatal, "\(message) - \(info ?? "")")
}

//MARK: -
public func logNil(_ instance:Any, _ info: String? = nil) {
    let message = "Unexpected nil \(info ?? "")"
    CrashReporter.capture(message)
    logMessage(instance, .error, message)
}

public func logNil(_ sourceInfo:SourceInfo, _ info: String? = nil) {
    let message = "Unexpected nil \(info ?? "")"
    logMessage(sourceInfo, .error, message)
    CrashReporter.capture(message)
}

fileprivate func makeTag(_ function: String, _ file: String, _ line: Int) -> String {
    return "\(file) \(function)[\(line)]"
}
