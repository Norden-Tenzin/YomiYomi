//
//  Extenssions.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation

extension FileManager {
    /// Checks if a file or folder at the given URL exists and if it is a directory or a file.
    /// - Parameter path: The path to check.
    /// - Returns: A tuple with the first ``Bool`` representing if the path exists and the second ``Bool`` representing if the found is a directory (`true`) or not (`false`).
    func fileExistsAndIsDirectory(atPath path: String) -> (Bool, Bool) {
        var fileIsDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &fileIsDirectory)
        return (fileExists, fileIsDirectory.boolValue)
    }
}
