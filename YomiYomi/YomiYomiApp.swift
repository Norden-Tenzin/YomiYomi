//
//  YomiYomiApp.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//

import SwiftUI

@main
struct YomiYomiApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        print("HERE")
        createDirectoryInDocuments(dirName: COMIC_LOCATION_NAME)
        createDirectoryInDocuments(dirName: COMIC_DATA_LOCATION_NAME)
        //        createJsonInDocuments(jsonName: DATA_FILE_NAME)
        //        print(readJSON(from: DATA_FILE_NAME, for: .documentDirectory).count)
        //        do {
        //            modelContainer = try ModelContainer(for: Comic.self)
        //        } catch {
        //            fatalError("Could not initialize ModelContainer")
        //        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
