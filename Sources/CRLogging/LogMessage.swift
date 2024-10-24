//
//  LogMessage.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

public struct LogMessage : LosslessStringConvertible, Sendable {
    public init(source: SourceInfo, messageId: MessageId, data: String? = nil) {
        self.source = source
        self.messageId = messageId
        self.data = data
    }
    
    public init?(_ description: String) {
        let subStr = description.substring(from: 0)
        var scanner = StringScanner(span: subStr, pos: 0, dir: 1)
        do {
            let id = try scanner.readInt64()
            try scanner.expect(c: " ")
            try scanner.expect(c: "\"")
            let typeStr = try scanner.readUntilMatch(c: "\"", maxChars: 255)
            self.source = SourceInfo(instanceId: id, type: String(typeStr))
            let messageId = try scanner.readUInt16()
            guard let msgId = MessageId(rawValue: messageId) else { return nil }
            self.messageId = msgId
            let dataStr = try scanner.read()
            if dataStr.count > 0 {
                self.data = String(dataStr)
            } else {
                self.data = nil
            }
        } catch {
            return nil
        }
    }
    
    public var description: String {
        if let data = data {
            return "\(source.description) \(messageId.rawValue) \(data)"
        } else {
            return "\(source.description) \(messageId.rawValue)"
        }
    }
    
    //let lineInfo:LineInfo
    public let source:SourceInfo
    public let messageId:MessageId
    //let dataId:UInt32 //error Id - will be embedded in string
    public let data:String?
}
