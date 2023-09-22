//
//  Catagory+CoreDataClass.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/19/23.
//
//

import Foundation
import CoreData

@objc(Catagory)
public class Catagory: NSManagedObject {
    convenience init(name: String, context: NSManagedObjectContext) {
        // Get the entity description from the context
        let entity = NSEntityDescription.entity(forEntityName: "Catagory", in: context)!

        // Call designated initializer
        self.init(entity: entity, insertInto: context)

        // Initialize properties
        self.id = UUID()
        self.name = name
    }
}
