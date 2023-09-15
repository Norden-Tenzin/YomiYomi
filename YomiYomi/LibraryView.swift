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

struct LibraryView: View {
    //    COREDATA
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Comic.id, ascending: true)],
        animation: .default)
    private var exisitingComics: FetchedResults<Comic>

    var demoText: String
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    func doesComicExist(comicName: String) -> Bool {
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

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(exisitingComics, id: \.self.id) { comic in
                    Card(comic: comic)
                }
            }
                .padding(.horizontal, 4)
                .background(Color.black)
        }
            .onAppear() {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(atPath: getDirectoryInDocuments(of: COMIC_LOCATION_NAME).path())
                for item in directoryContents {
                    if doesComicExist(comicName: item) {
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
                            addComic(tempComic)
                        } else {
                            let tempComic = Comic(name: item, dateAdded: Date.now, context: viewContext)
                            let originalLocation = COMIC_LOCATION_NAME + "/\(item)"
                            let tempChapter = Chapter(name: item, chapterLocation: originalLocation, comic: tempComic, context: viewContext)
                            tempComic.chapters = NSSet(array: [tempChapter])
                            addComic(tempComic)
                        }
                    }
                }
            } catch {
                print("Error while retrieving directory contents: \(error)")
            }
        }
    }

    private func addComic(_ comic: Comic) {
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

    private func deleteComic(_ comic: Comic) {
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
}
