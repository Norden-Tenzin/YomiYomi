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
        createDirectoryInDocuments(dirName: COMIC_LOCATION_NAME)
        createDirectoryInDocuments(dirName: COMIC_DATA_LOCATION_NAME)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
