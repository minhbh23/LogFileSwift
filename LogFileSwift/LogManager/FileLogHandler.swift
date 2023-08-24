//
//  FileLogHandler.swift
//  TestLog
//
//  Created by Paraline App on 11/08/2023.
//

import Foundation

struct FileHandlerOutputStream: TextOutputStream {

    enum FileHandlerOutputStream: Error {
        case couldNotCreateFile
        case fileNotFound
        case canNotRemoveFile
        case fileDeleteFalse
    }

    private let fileHandle: FileHandle

    let encoding: String.Encoding

    /// Create file log `fileLogFolder` and file log.text `Level`
    init(folderName log: String, encoding: String.Encoding = .utf8) throws {
        let fileManager = FileManager.default
        let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = tDocumentDirectory?.appendingPathComponent(FileLogHandler.FolderName.fileLogFolder)

        do {
            try fileManager.createDirectory(atPath: filePath!.path, withIntermediateDirectories: true, attributes: nil)
            let file = filePath?.appendingPathComponent(log)
            if !fileManager.fileExists(atPath: file!.path) {
                fileManager.createFile(atPath: file!.path, contents: nil)
            }
            let fileHandle = try FileHandle(forWritingTo: file!)
            fileHandle.seekToEndOfFile()
            self.fileHandle = fileHandle
            self.encoding = encoding
        } catch {
            throw FileHandlerOutputStream.couldNotCreateFile
        }
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
    
    /// remove log
    /// - Parameter log: name file remove `Level`
    static func removeFileLog(folderName log: Logger.Level) throws {
        let fileManager = FileManager.default
        if let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFilePath = document.appendingPathComponent(FileLogHandler.FolderName.fileLogFolder)
            let filePaths = logFilePath.appendingPathExtension(log.rawValue + "\(Logger.timestampDay()).txt")
            do {
                try fileManager.removeItem(at: filePaths)
                print("--------------- File deleted ---------------")
            }
            catch {
                print("--------------- Error ---------------")
                throw FileHandlerOutputStream.fileDeleteFalse
                
            }
        }
    }
    
    /// get `Directory`
    /// - Parameter log: name file log `Level`
    /// - Returns: `URl` file disk
    static func getDirectoryLog(folderName log: Logger.Level) throws -> URL? {
        let fileManager = FileManager.default
        if let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFilePath = document.appendingPathComponent(FileLogHandler.FolderName.fileLogFolder)
            let filePath = logFilePath.appendingPathComponent(log.rawValue + "\(Logger.timestampDay()).txt")
            if !fileManager.fileExists(atPath: filePath.path) {
                print("--------------- file Not Found -----------------")
                throw FileHandlerOutputStream.fileNotFound
            }
            return filePath
        }
        return nil
    }
}

/// `FileLogHandler` is a simple implementation of `LogHandler` for directing
/// `Logger` output to a local file. Appends log output to this file, even across constructor calls.
public struct FileLogHandler {

    public struct FolderName {
        static let fileLogFolder = "fileLog"
    }

    private var stream: TextOutputStream
    private let numberWrite = 1000

    public static var logLevel: Logger.Level = .info

    private var prettyMetadata: String?
    
    private var uiid: String {
        return UUID().uuidString
    }
    
    private var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    public init(folderName log: String) throws {
        self.stream = try FileHandlerOutputStream(folderName: log + "\(Logger.timestampDay()).txt")
    }

    /// write data `String` to file log local
    /// - Parameters:
    ///   - level: `level` log
    ///   - message: `Message` log
    ///   - metadata: `Metadata`log `Dictionary`
    ///   - source: nil
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String?) {
        let prettyMetadata = metadata?.isEmpty ?? true
        ? self.prettyMetadata
        : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: {_, new in new}))

        var stream = self.stream
        if isWriteData(level: level) {
            do {
                let newStream = try FileHandlerOutputStream(folderName:"\(level.rawValue)\(Logger.timestampDay()).txt")
                stream = newStream
            } catch {
                print(error)
            }
        }
        if !isCreateLog(level: level) {
            stream.write("uiid: \(uiid) || device: IOS || appVersion: \(appVersion ?? "") \n \n")
        }
        stream.write("\(Logger.timestamp()) \(level.levelString): \(prettyMetadata.map { " \($0)" } ?? "") \(message.description)\n")
    }
    
    private func isCreateLog(level: Logger.Level) -> Bool {
        do {
            guard let fileUrlString = try FileHandlerOutputStream.getDirectoryLog(folderName: level) else {
                return false
            }
            let contentLog = Logger.getContentLog(fileUrl: fileUrlString)
            let content = "uiid: \(uiid) || device: IOS || appVersion: \(appVersion ?? "") \n \n"
            return contentLog.contains(content)
        } catch {
            print(error)
            return false
        }
    }

    /// Check linited content log
    /// - Parameter level: `level` description
    /// - Returns: `Bool` limited WriteData
    private func isWriteData(level: Logger.Level) -> Bool {
        do {
            guard let fileUrlString = try FileHandlerOutputStream.getDirectoryLog(folderName: level) else {
                return true
            }
            let contentLog = Logger.getContentLog(fileUrl: fileUrlString)
            let count =  contentLog.components(separatedBy: level.levelString).count
                print("<-------------------------------------> log content: \(count) <--------------------------------------->")
            return count <= numberWrite
        } catch {
            print(error)
            return true
        }
    }

    /// auto upload file when linit content insert
    /// - Parameter level: `level` description
    private func upLoadFileLogToFirebase(level: Logger.Level) {
        do {
            guard let fileUrlString = try FileHandlerOutputStream.getDirectoryLog(folderName: level) else {
                print("--------------- file Not Found -----------------")
                return
            }
            StorageLog.shaze.uploadFile(localFile: fileUrlString, fileName: level.rawValue) { metaData, error in
                guard let error = error else {
                    print("--------------- file uploadSuccess -----------------")
                    return
                }
                print(error)
            }
        } catch {
            print(error)
        }
    }

    /// handle Metadata
    /// - Parameter metadata: `Logger.Metadata`
    /// - Returns: metaData`String`
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
}
