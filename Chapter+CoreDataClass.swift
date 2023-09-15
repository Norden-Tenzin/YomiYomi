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
        self.totalPageNumber = 0
    }

    func toString() -> String {
        return "Name: \(self.name!), CurrPage: \(self.currPageNumber)"
    }
}
