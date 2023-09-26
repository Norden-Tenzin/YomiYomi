//
//  LibraryView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/18/23.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Catagory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Catagory.pos, ascending: true)],
        animation: .default) private var catagories: FetchedResults<Catagory>
    @State var selection: Int = 0
    let minDragTranslationForSwipe: CGFloat = 50

    func deleteAllComics() {
//        Comic Does Exist
//        TODO: ADD CODE FOR SEARCHING AND UPDATING CHAPTERS
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Comic")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
        } catch {
            // TODO: handle the error
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TabBarView(currTab: $selection)
                TabView(selection: $selection,
                    content: {
                        CatagoryView(catagoryName: nil)
                            .tag(0)
                        ForEach(catagories, id: \.id) { cat in
                            CatagoryView(catagoryName: cat.name)
                                .tag(Int(cat.pos))
                        }
                    })
                    .tabViewStyle(.page(indexDisplayMode: .never))
            }
                .navigationTitle("Library")
                .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { deleteAllComics() }, label: {
                            HStack {
                                Text("DEBUG")
                                Image(systemName: "trash.fill")
                            }
                        })
                        .background(Color.green)
                    Button(action: { refresh(viewContext: viewContext) }, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                    Button(action: { addComic(Comic(name: "DEBUG", dateAdded: Date(), context: viewContext), viewContext: viewContext) }, label: {
                            Image(systemName: "plus")
                        })
                }
            }
        }
    }
}

struct TabBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Catagory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Catagory.pos, ascending: true)],
        animation: .default) private var catagories: FetchedResults<Catagory>
    @Binding var currTab: Int
    @Namespace var nameSpace
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                TabBarItem(currTab: $currTab, nameSpace: nameSpace.self, tabName: "All", tab: 0)
                ForEach(catagories) { cat in
                    TabBarItem(currTab: $currTab, nameSpace: nameSpace.self, tabName: cat.name!, tab: Int(cat.pos))
                }
                Spacer()
            }
                .padding(.horizontal)
        }
            .background(.regularMaterial)
            .frame(height: 32)
    }
}

struct TabBarItem: View {
    @Binding var currTab: Int
    let nameSpace: Namespace.ID
    let tabName: String
    let tab: Int

    var body: some View {
        VStack {
            Spacer()
            Text(tabName)
                .padding(.vertical, 5)
            if currTab == tab {
                Color.primary
                    .frame(height: 3)
                    .matchedGeometryEffect(id: "underline", in: nameSpace, properties: .frame)
            } else {
                Color.clear
                    .frame(height: 3)
            }
        }
            .animation(.spring(duration: 0.15), value: self.currTab)
            .onTapGesture {
            currTab = tab
        }
    }
}

struct TabItemView: View {
    var bgColor: Color
    var body: some View {
        bgColor
            .ignoresSafeArea()
    }
}

