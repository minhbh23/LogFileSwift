//
//  Utilz.swift
//  TestLog
//
//  Created by Paraline App on 11/08/2023.
//

import Foundation

public struct Logger {

    public typealias Metadata = [String: Any]
    public typealias Message = MessageLoger
    public typealias Level = LevelLoger

    public enum LevelLoger: String {
        case trace = "trace"
        case debug = "debug"
        case info = "info"
        case notice = "notice"
        case warning = "warning"
        case error = "error"
        case critical = "critical"
        
        var levelString: String {
            switch self {
            case .trace:
                return "[trace]"
            case .debug:
                return "[debug]"
            case .info:
                return "[info]"
            case .notice:
                return "[notice]"
            case .warning:
                return "[warning]"
            case .error:
                return "[error]"
            case .critical:
                return "[critical]"
            }
        }
    }

    private var loggerHandle: FileLogHandler?
    private var folderName: LevelLoger = .debug
    private let DEBUG_LEVEL = 5

    private init() {}

    private init(folderName log: Level) throws {
        self.loggerHandle = try FileLogHandler(folderName: log.rawValue)
    }

    static func log(folderName: Level) -> Logger {
        do {
            let log = try Logger(folderName: folderName)
            return log
        }
        catch {
            print("\(error)")
            return Logger()
        }
    }
    
    /// Log message `Level Trace`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func trace(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .trace, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Debug`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log.
    func debug(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .debug, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Info`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func info(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .info, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Notice`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func notice(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .notice, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Warning`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func warning(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .warning, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Error`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func
    error(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .error, message: logMessage, metadata: metadata, source: nil)
    }

    /// Log message `Level Critical`
    /// - Parameters:
    ///   - logMessage: `Message` log
    ///   - metadata: `metadata` log
    ///   - functionName: `functionName`  log
    ///   - line: `line` log
    ///   - fileName: `fileName` log
    ///   - column :  `column` log
    func critical(_ logMessage: Message, metadata: Logger.Metadata?, functionName: String = #function, line: UInt = #line, fileName: String = #file, column _: Int = #column) {
        guard let loggerHandle = self.loggerHandle else {return}
        loggerHandle.log(level: .critical, message: logMessage, metadata: metadata, source: nil)
    }
    
    /// `BLog` print log
    /// - Parameters:
    ///   - logMessage: `logMessage` description
    ///   - functionName: `functionName` description
    ///   - line: `line` description
    ///   - fileName: `fileName` description
    ///   - column: `column` description
    public func BLog(_ logMessage: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column _: Int = #column) {
        #if DEBUG
            Swift.print("[\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)")
        #endif
    }

    /// `BLogDebug` print log
    /// - Parameters:
    ///   - logMessage: `logMessage` description
    ///   - functionName: `functionName` description
    ///   - line: `line` description
    ///   - fileName: `fileName` description
    ///   - column: `column` description
    public func BLogDebug(_ logMessage: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column _: Int = #column) {
        if DEBUG_LEVEL == 1 || DEBUG_LEVEL == 5 {
            #if DEBUG
                Swift.print("💜[DEBUG][\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)")
            #endif
        }
    }

    /// `BLogInfo` print log
    /// - Parameters:
    ///   - logMessage: `logMessage` description
    ///   - functionName: `functionName` description
    ///   - line: `line` description
    ///   - fileName: `fileName` description
    ///   - column: `column` description
    public func BLogInfo(_ logMessage: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column _: Int = #column) {
        if DEBUG_LEVEL == 2 || DEBUG_LEVEL == 5 {
            #if DEBUG
                Swift.print("💚[INFO][\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)")
            #endif
        }
    }

    /// `BLogWarning` print log
    /// - Parameters:
    ///   - logMessage: `logMessage` description
    ///   - functionName: `functionName` description
    ///   - line: `line` description
    ///   - fileName: `fileName` description
    ///   - column: `column` description
    public func BLogWarning(_ logMessage: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column _: Int = #column) {
        if DEBUG_LEVEL == 3 || DEBUG_LEVEL == 5 {
            #if DEBUG
                Swift.print("💛[WARNING][\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)")
            #endif
        }
    }

    /// `BLogError` print log
    /// - Parameters:
    ///   - logMessage: `logMessage` description
    ///   - functionName: `functionName` description
    ///   - line: `line` description
    ///   - fileName: `fileName` description
    ///   - column: `column` description
    public func BLogError(_ logMessage: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column _: Int = #column) {
        if DEBUG_LEVEL == 4 || DEBUG_LEVEL == 5 {
            #if DEBUG
                Swift.print("❤️[ERROR][\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)")
            #endif
        }
    }

    /// create time log
    /// - Returns: time`String`
    static func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }

    /// create day
    /// - Returns: time`String`
    static func timestampDay() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%d", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }

    /// print conten file log
    /// - Parameter fileUrlString: file `URL` string
    static func printContentLog(fileUrl: URL) {
        do {
            let text2 = try String(contentsOf: fileUrl, encoding: .utf8)
            print("<-----> \(text2) <---->")
        }
        catch {
            print("<-----> conten not found <---->")
        }
    }

    /// get conten file log
    /// - Parameter fileUrlString: file `URL` string
    /// - Returns: `String` conten log
    static func getContentLog(fileUrl: URL) -> String {
        do {
            let text = try String(contentsOf: fileUrl, encoding: .utf8)
            return text
        }
        catch {
            print("<-----> conten not found <---->")
            return ""
        }
    }
}

public struct MessageLoger {

    private var value: String
    private var functionName: String
    private var line: Int
    private var fileName: String
    private var column: Int

    public init(stringLiteral value: String, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
        self.value = value
        self.functionName = functionName
        self.line = line
        self.fileName = fileName
        self.column = column
    }

    /// content log insert to file logcal
    public var description: String {
        return log(self.value, functionName: self.functionName,
                   line: self.line, fileName: self.fileName, column: self.column)
    }

    /// handle log message
    /// - Parameters:
    ///   - logMessage: `logMessage description`
    ///   - functionName: `functionName description
    ///   - line: `line description
    ///   - fileName: `fileName description
    ///   - column: `column description
    /// - Returns: `String` content log
    func log(_ logMessage: String, functionName: String, line: Int, fileName: String, column _: Int) -> String {
        #if DEBUG
        return "[\((fileName as NSString).lastPathComponent)] - [Line \(line)] - [\(functionName)]: \(logMessage)"
        #endif
    }
}
