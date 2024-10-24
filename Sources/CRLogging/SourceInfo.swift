//
//  SourceInfo.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

public struct SourceInfo : LosslessStringConvertible, Sendable {
              
    public let instanceId:Int64
    public let type:String
    
    public init(instance: Any) {
        let mirror = Mirror(reflecting: instance)
        if (mirror.displayStyle == .class) { // Can also check via (type(of: instance) is AnyClass)
            self.instanceId = Int64(ObjectIdentifier(instance as AnyObject).hashValue)
        } else {
            self.instanceId = 0
        }
        self.type = String(describing: mirror.subjectType)
    }
         
    public init(instanceId: Int64, type: String) {
        self.instanceId = instanceId
        self.type = type
    }
    
    public init?(_ description: String) {
        let subStr = description.substring(from: 0)
        var scanner = StringScanner(span: subStr, pos: 0, dir: 1)
        do {
            let id = try scanner.readInt64()
            try scanner.expect(c: " ")
            try scanner.expect(c: "\"")
            let typeStr = try scanner.readUntilMatch(c: "\"", maxChars: 255)
            self.instanceId = id
            self.type = String(typeStr)
        } catch {
            return nil
        }
    }
    
    public var description: String {
        return "\(instanceId) \"\(type)\""
    }
    
}
