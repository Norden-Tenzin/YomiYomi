//
//  ContentView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    let tabs: [Tab] = [
            .init(icon: Image(systemName: "music.note"), title: "Music"),
//            .init(icon: Image(systemName: "film.fill"), title: "Movies"),
//            .init(icon: Image(systemName: "book.fill"), title: "Books")
    ]

    init() {
        print("HERE1")
//        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
//            print("Documents Directory: \(documentsPath)")
//        }
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(Color.black)
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//        UINavigationBar.appearance().isTranslucent = false
    }

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Tabs
                    Tabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
                    // Views
                    TabView(selection: $selectedTab,
                        content: {
                            LibraryView(demoText: "Music View")
                                .tag(0)
                            //                            LibraryView(demoText: "Movies View")
                            //                                .tag(1)
                            //                            LibraryView(demoText: "Books View")
                            //                                .tag(2)
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                    .foregroundColor(Color.black)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Library")
            }
        }
    }
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
