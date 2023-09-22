//
//  Persistence.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 1..<11 {
//            let newCatagory = Catagory(name: "Default", context: viewContext)
            let newCatagory = Catagory(context: viewContext)
            newCatagory.id = UUID()
            newCatagory.name = "default"
            newCatagory.comic = nil
            newCatagory.pos = Int64(index)

            let newComic = Comic(context: viewContext)
            newComic.id = UUID()
            newComic.name = "DEMO"
            newComic.catagory = nil
            newComic.chapters = {
                var chs = []
                for i in stride(from: 0, to: 10, by: 1) {
                    let ch = Chapter(context: viewContext)
                    ch.id = UUID()
                    ch.name = "SOMECHAPTER"
                    ch.pages = []
                    ch.currPageNumber = 0
                    ch.totalPageNumber = 10
                    ch.chapterLocation = ""
                    chs.append(ch)
                }
                return NSSet(array: chs)
            }()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "YomiYomi")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
