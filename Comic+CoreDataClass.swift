//
//  Comic+CoreDataClass.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//
//

import Foundation
import CoreData

@objc(Comic)
public class Comic: NSManagedObject {
    convenience init(name: String, dateAdded: Date, context: NSManagedObjectContext) {
        // Get the entity description from the context
        let entity = NSEntityDescription.entity(forEntityName: "Comic", in: context)!

        // Call designated initializer
        self.init(entity: entity, insertInto: context)

        // Initialize properties
        self.id = UUID()
        self.name = name
        self.dateAdded = dateAdded
        self.lastUpdated = dateAdded
        self.cover = ""
        self.chapters = []
    }
}
