//
//  ContentView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/5/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var currentMode
    @State var newSelection: CustomTabBarItem = CustomTabBarItem(img: "books.vertical.fill", text: "library")
    private var tabs: [CustomTabBarItem] = [CustomTabBarItem(img: "books.vertical.fill", text: "library"), CustomTabBarItem(img: "gear", text: "settings")]
    var body: some View {
        TabView(selection: $newSelection) {
            Group {
                LibraryView()
                    .tabItem {
                    VStack {
                        Image(systemName: "books.vertical.fill")
                        Text("library")
                    }
                }
                SettingsView()
                    .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("settings")
                    } }
            }
//                    .toolbar(.visible, for: .tabBar)
//                    .toolbarBackground(.regularMaterial, for: .tabBar)
        }
            .tint(currentMode == .dark ? .white : .black)
            .onAppear() {
            UITabBar.appearance().backgroundColor = UIColor(named: "navbar")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
