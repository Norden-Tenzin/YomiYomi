//
//  ComicDetailView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI
import CoreData

struct ComicDetailView: View {
//    @Environment(\.colorScheme) var currentMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var chapters: FetchedResults<Chapter>
    @State private var currChapter: Chapter?
    @State var isPopoverActive: Bool = false
    var comic: Comic

    init(comic: Comic) {
        self.comic = comic
        _chapters = FetchRequest(
            entity: Chapter.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Chapter.name, ascending: true)],
            predicate: NSPredicate(format: "comic == %@", comic)
        )
    }

    func closeFullScreenCover(deleteLocation: String) -> Void {
        currChapter = nil
        do {
            if FileManager.default.fileExists(atPath: deleteLocation) {
                try FileManager.default.removeItem(atPath: deleteLocation)
            }
            viewContext.refreshAllObjects()
        } catch {
            print ("Error removing file: \(error)")
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    let image: UIImage? = UIImage(contentsOfFile: getDirectoryInDocuments(of: comic.cover ?? "").path)
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable()
                            .aspectRatio(5.1 / 7.2, contentMode: .fit)
                            .cornerRadius(8)
                    } else {
                        Color.black
                            .aspectRatio(5.1 / 7.2, contentMode: .fit)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(comic.name ?? "Anonymous")
                            .font(.system(size: 24, weight: .bold))
                            .lineLimit(nil)
                        HStack {
                            ZStack {
                                Color.quaternaryLabel
                                Image(systemName: "bookmark.fill")
                            }
                                .foregroundColor(.blue)
                                .frame(width: 35, height: 30)
                                .cornerRadius(8.0)
                                .onTapGesture {
                                isPopoverActive.toggle()
                            }
                                .popover(isPresented: $isPopoverActive,
                                attachmentAnchor: .point(.center),
                                arrowEdge: .bottom) {
                                PopOverView(comic: comic)
                                    .presentationCompactAdaptation(.none)
                            }
                            ZStack {
                                Color.quaternaryLabel
                                Image(systemName: "globe")
                            }
                                .foregroundColor(.blue)
                                .frame(width: 35, height: 30)
                                .cornerRadius(8.0)
                                .onTapGesture {
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chapter")
                                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                                fetchRequest.predicate = NSPredicate(format: "comic == %@", comic)
                                do {
                                    let result = try viewContext.fetch(fetchRequest) as! [Chapter]
                                    result.map { chap in
                                        chap.currPageNumber = 0
                                    }
                                    try viewContext.save()
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                    }
                    Spacer()
                }
                    .frame(maxHeight: 180)
                Text("Desc... lorem Ipsum")
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
                Text("\(chapters.count) Chapters")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 10)
                Divider()
                VStack (alignment: .leading) {
                    ForEach(chapters.sorted(by: { c1, c2 in
                        return c1.name! < c2.name!
                    }), id: \.id) { chapter in
                        ComicDetailListItem(currChapter: $currChapter, chapter: chapter)
                        Divider()
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
                .padding(20)
                .fullScreenCover(item: $currChapter, content: { currChapter in
                ComicView(chapter: currChapter, comic: comic, close: closeFullScreenCover)
            })
        }
            .onAppear() {
            viewContext.refreshAllObjects()
        }
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PopOverView: View {
    @FetchRequest(
        entity: Catagory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Catagory.pos, ascending: true)],
        animation: .default) private var catagories: FetchedResults<Catagory>
    var comic: Comic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(catagories, id: \.self) { cat in
                    PopOverItem(catagory: cat, comic: comic)
                    if cat.id != catagories.last?.id {
                        Divider()
                    }
                }
            }
        }
            .padding(10)
            .frame(width: 200)
    }
}

struct PopOverItem: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var checked = false
    let catagory: Catagory
    var comic: Comic

    init(catagory: Catagory, comic: Comic) {
        self.checked = comic.catagory?.contains(catagory) ?? false
        self.catagory = catagory
        self.comic = comic
    }

    func toggleCatagory() {
        //        check if cat exists in the array
        let comicCatagories = Array(comic.catagory as! Set<Catagory>)
        if comicCatagories.contains(catagory) {
            //        if it does exits remove
            do {
                comic.catagory = NSSet(array: comicCatagories.filter { cat in cat != catagory })
                try viewContext.save()
            } catch {
                print("Error: \(error)")
            }
        } else {
            //        if not add
            do {
                comic.catagory = NSSet(array: comicCatagories + [catagory])
                try viewContext.save()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    var body: some View {
        Toggle(isOn: $checked) {
            Text(catagory.name!)
        }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: checked) { oldValue, newValue in
            toggleCatagory()
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .foregroundColor(configuration.isOn ? .blue : .gray)
        }
            .font(.system(size: 18, weight: .regular, design: .default))
            .onTapGesture { configuration.isOn.toggle() }
    }
}

//#Preview {
//    @Environment(\.managedObjectContext) var viewContext
//    ComicDetailView(comic: Comic(name: "BERZERK", dateAdded: Date(), context: viewContext))
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
