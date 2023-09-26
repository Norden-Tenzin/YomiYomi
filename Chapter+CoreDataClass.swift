//
//  Chapter+CoreDataClass.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//
//

import Foundation
import CoreData

@objc(Chapter)
public class Chapter: NSManagedObject {
    convenience init(name: String, chapterLocation: String, comic: Comic, context: NSManagedObjectContext) {
        // Get the entity description from the context
        let entity = NSEntityDescription.entity(forEntityName: "Chapter", in: context)!

        // Call designated initializer
        self.init(entity: entity, insertInto: context)

        // Initialize properties
        self.id = UUID()
        self.name = name
        self.chapterLocation = chapterLocation
        self.comic = comic
        self.pages = []
        self.currPageNumber = 0
        self.totalPageNumber = Int64(getNumberOfFilesInZip(at: getDirectoryInDocuments(of: chapterLocation)))
    }

    func toString() -> String {
        return "Name: \(self.name ?? "nil")"
    }

    func getName() -> String {
        return self.name ?? "nil"
    }
}
