//
//  Comic+CoreDataProperties.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//
//

import Foundation
import CoreData


extension Comic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comic> {
        return NSFetchRequest<Comic>(entityName: "Comic")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var cover: String?
    @NSManaged public var chapters: [Chapter]?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var lastUpdated: Date?

}

extension Comic : Identifiable {

}
