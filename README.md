### CRLogging

Logging functions. What differentiate this from others is that I try to save the instance id (or fall back to filename) for each log. The idea is that in the future I can inspect logs from only a single instance with some filtering.

Example Use:

```
    let reporter = SentryCrashReporter()
    CrashReporter.reporter = reporter
    reporter.start()
        
    logMessage(.info, "Request successful")
    logAndReportError("Unexpected status code \(httpResponse.statusCode)")
    guard let myExpectedItem = mainContext.object(with: itemId) as? Item else {
        logNil("myExpectedItem")
        return
    }
    logMessage(myExpectedItem, .instanceInit)
    logMessage(myExpectedItem, .error, "Something wrong, but dont report")
    
    do {
       throw Error()
    } catch {
        logAndReportException(ex, "Failed to do something")
    }
}
```

Example result:
```
91239821 "MyItemType" 7 Some error info or message
0 "URLSession+Async.swift" 2 Request successful
```
Seems like there is room for improvement. I could include file row and column

There is also a callback interface called CrashReporter that lets the user forward info to some sort of error service like Sentry or write with a logging system like CocoaLumberjack
```
public protocol ICrashReporter {
    func capture(_ message:String, info:String?)
    func capture(_ error:Error, info:String?)
    func capture(_ exception:NSException, info:String?)
    func writeToFile(_ message:String)
}
```

Example CrashReporter Implementation:
```

public struct Attachment {
    public let data:Data
    public let fileName:String
    public let mimeType:String
    
    public init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public class SentryCrashReporter : ICrashReporter {
    public func writeToFile(_ message: String) {
        DDLogDebug(message)
    }
    
    public var onAttachFile: (() -> (URL, String)?)? = nil

    public func start(_ isDebug:Bool, _ enabled:Bool) {
        SentrySDK.start { options in
            options.dsn = "abc123"
            options.enableTracing = false
            options.diagnosticLevel = .error
            options.enabled = enabled
            options.attachStacktrace = true
            
            #if DEV
                #if DEBUG
                    options.environment = "dev-debug"
                #else
                    options.environment = "dev"
                #endif
            #else
                #if DEBUG
                    options.environment = "production-debug"
                #else
                    options.environment = "production"
                #endif
            #endif
            
            options.attachScreenshot = true
            options.attachViewHierarchy = true
            
            options.beforeSend = { [weak self] (newEvent:Sentry.Event?) in
                guard let myEvent = newEvent else { return nil }
                if (myEvent.exceptions == nil && myEvent.error == nil) {
                    return myEvent;
                }
                //if (myEvent.isAppHangEvent) { return newEvent; }
                
                myEvent.attachments = self?.attachments().map({
                    return Sentry.Attachment(data: $0.data, filename: $0.fileName, contentType: $0.mimeType)
                })
                return myEvent
            }
        }
        
        NSSetUncaughtExceptionHandler { exception in
            SentrySDK.capture(exception: exception) { (scope:Scope) in
                scope.setLevel(.fatal)
            }
            Thread.sleep(forTimeInterval: 3)
        }
    }
    
    public func capture(_ message:String, info:String? = nil) {
        SentrySDK.capture(message: message) { (scope:Scope) in
           if let data = info {
               scope.setExtra(value: data, key: "info")
           }
       }
    }
    
    public func capture(_ error:Error, info:String? = nil) {
        SentrySDK.capture(error: error) { (scope:Scope) in
           if let data = info {
               scope.setExtra(value: data, key: "info")
           }
       }
    }
    
    public func capture(_ exception:NSException, info:String? = nil) {
        SentrySDK.capture(exception: exception) { (scope:Scope) in
           if let data = info {
               scope.setExtra(value: data, key: "info")
           }
       }
    }
    
    public func attachments() -> [Attachment] {
        let result = getZippedAttachment() ?? getSingleLogAttachment() ?? []
        return result
    }
    
    public func getZippedAttachment() -> [Attachment]? {
        do {
            let logsUrl = try DebugUtil.zipLogsResult().get()
            return urlToAttachment(url: logsUrl, contentType: "application/zip")
        } catch {
            logMessage(.warning, error.localizedDescription)
        }
        return nil
    }
    
    public func getSingleLogAttachment() -> [Attachment]? {
        let logsUrl = []
        return urlToAttachment(url: logsUrl, contentType: "text/plain")
    }
    
    func urlToAttachment(url:URL, contentType:String) -> [Attachment]? {
        do {
            let data = try Data.init(contentsOf: url)
            let logsAttachment = Attachment(data: data, fileName: url.lastPathComponent, mimeType: contentType)
            return [logsAttachment]
        } catch {
            let msg = "Exception Thrown: \(String(describing:error)) - Unable to create attachment from url: \(url.absoluteString)"
            logMessage(self, .error, msg)
            return nil
        }
    }
}

```
