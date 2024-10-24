//
//  WriteToFile.swift
//  CRLogging
//
//  Created by Isaac Paul on 10/24/24.
//

import Foundation

public func initLoggingLock() {
    pthread_rwlock_init(&lock, nil)
}

fileprivate var lock = pthread_rwlock_t() //Had this as a function to avoid initLoggingLock but that seemed to cause a race condition

public func writeToFile(_ message:String) {
    pthread_rwlock_wrlock(&lock)
    CrashReporter.writeToFile(message)
    pthread_rwlock_unlock(&lock)
}
