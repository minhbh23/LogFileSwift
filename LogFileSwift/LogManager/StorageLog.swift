//
//  StorageLog.swift
//  TestLog
//
//  Created by Paraline App on 16/08/2023.
//

import Foundation
import FirebaseCore
import Firebase
import FirebaseStorage
import FirebaseAuth

class StorageLog {

    private var storage: Storage
    private var storageRef: StorageReference

    private init() {
        self.storage = Storage.storage()
        self.storageRef = self.storage.reference()
    }

    static var shaze = StorageLog()

    /// Create a storage reference from our storage service
    /// - Parameters:
    ///   - localFile: File located on disk
    ///   - fileName: Name File log
    ///   - completion:  `Metadata` contains file metadata such as size,` content-type`. `Error`
    func uploadFile(localFile: URL, fileName: String, completion: @escaping (_ metaData: StorageMetadata?,
                                                                            _ error: Error?) -> Void) {
        // Create a reference to the file to upload
        let riversRef = storageRef.child("\(fileName).txt")
        _ = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("<-----------------------> /n \(error!) /n <------------------------>")
                return
            }
            completion(metadata, error)
        }
    }

    /// Download file from `FirebaseStorage`
    /// - Parameters:
    ///   - fileName: Name file Download
    ///   - completion: `URL` download from `FirebaseStorage`,  `Error`
    func dowLoadFile(fileName: String, completion: @escaping (URL?, _ error: Error?) -> Void) {
        // Create a reference to the file to download
        let riversRef = storageRef.child("\(fileName).txt")
        riversRef.downloadURL { (url, error) in
            completion(url, error)
        }
    }

    /// RemoveFile from `FirebaseStorage`
    /// - Parameters:
    ///   - fileName: Name file Romove
    ///   - completion: `Error`, handle `Error nil` remove successfully else
    func removeFile(fileName: String, completion: @escaping (_ error: Error?) -> Void) {
        // Create a reference to the file to delete
        let desertRef = storageRef.child("\(fileName).txt")
        desertRef.delete { error in
            completion(error)
        }
    }
}
