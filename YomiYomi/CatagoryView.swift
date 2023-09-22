//
//  LibraryView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI
import CoreData
import ZipArchive

struct CatagoryView: View {
    @Environment(\.colorScheme) var currentMode
    //    COREDATA
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest
    var exisitingComics: FetchedResults<Comic>
    var catagoryName: String?
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    init(catagoryName: String?) {
        let request: NSFetchRequest<Comic> = Comic.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Comic.name, ascending: true)]
        if let catagoryName = catagoryName {
            print(catagoryName)
            request.predicate = NSPredicate(format: "ANY catagory.name == %@", catagoryName)
        }
        _exisitingComics = FetchRequest<Comic>(fetchRequest: request)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(exisitingComics, id: \.self.id) { comic in
                    Card(comic: comic)
                }
            }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(currentMode == .dark ? .black : .white)
        }
            .refreshable {
            refresh(viewContext: viewContext)
        }
    }
}

func addComic(_ comic: Comic, viewContext: NSManagedObjectContext) {
    withAnimation {
        do {
            viewContext.insert(comic)
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

func deleteComic(_ comic: Comic, viewContext: NSManagedObjectContext) {
    withAnimation {
        do {
            viewContext.delete(comic)
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

func refresh(viewContext: NSManagedObjectContext) {
    func doesComicExist(comicName: String, exisitingComics: [Comic]) -> Bool {
        if exisitingComics.firstIndex(where: { comic in
            comic.name == comicName
        }) != nil {
            return true
        } else {
            return false
        }
    }
    func findChapters(directoryContents: [String], item: String, tempComic: Comic) -> NSSet {
        var res: [Chapter] = []
        for innerItem in directoryContents {
            let originalLocation = COMIC_LOCATION_NAME + "/\(item)/\(innerItem)"
            let tempChapter = Chapter(name: innerItem, chapterLocation: originalLocation, comic: tempComic, context: viewContext)
            res.append(tempChapter)
        }
        return NSSet(array: res)
    }
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comic")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
    do {
        let exisitingComics = try viewContext.fetch(fetchRequest) as! [Comic]

        let directoryContents = try FileManager.default.contentsOfDirectory(atPath: getDirectoryInDocuments(of: COMIC_LOCATION_NAME).path())
        for item in directoryContents {
            if doesComicExist(comicName: item, exisitingComics: exisitingComics) {
                //                    Comic Does Exist
                //                    TODO: ADD CODE FOR SEARCHING AND UPDATING CHAPTERS
                //                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Comic")
                //                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                //                        do {
                //                            try viewContext.execute(deleteRequest)
                //                        } catch {
                //                            // TODO: handle the error
                //                        }
            } else {
                //                    Comic Doesnt Exist
                let isDir = FileManager.default.fileExistsAndIsDirectory(atPath: getDirectoryInDocuments(of: COMIC_LOCATION_NAME).path + "/" + item).1
                if isDir {
                    let tempComic = Comic(name: item, dateAdded: Date.now, context: viewContext)
                    let directoryContents = try FileManager.default.contentsOfDirectory(atPath: getDirectoryInDocuments(of: COMIC_LOCATION_NAME).path() + "/\(item)/")
                    tempComic.chapters = findChapters(directoryContents: directoryContents, item: item, tempComic: tempComic)
                    addComic(tempComic, viewContext: viewContext)
                } else {
                    let tempComic = Comic(name: item, dateAdded: Date.now, context: viewContext)
                    let originalLocation = COMIC_LOCATION_NAME + "/\(item)"
                    let tempChapter = Chapter(name: item, chapterLocation: originalLocation, comic: tempComic, context: viewContext)
                    tempComic.chapters = NSSet(array: [tempChapter])
                    addComic(tempComic, viewContext: viewContext)
                }
            }
        }
    } catch {
        print("Error: \(error)")
    }
}

#Preview {
    CatagoryView(catagoryName: nil)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
