//
//  ComicDetailView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI

struct ComicDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currChapter: Chapter?
    @FetchRequest private var chapters: FetchedResults<Chapter>
    let comic: Comic

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
                    }
                    VStack {
                        Text(comic.name ?? "Anonymous")
                            .foregroundColor(Color.white)
                            .lineLimit(nil)
                        Spacer()
                    }
                    Spacer()
                }
                    .frame(maxHeight: 180)
                Text("Desc... lorem Ipsum")
                Text("\(chapters.count) Chapters")
                    .font(.system(size: 20))
                Divider()
                VStack (alignment: .leading) {
                    ForEach(chapters.sorted(by: { c1, c2 in
                        return c1.name! < c2.name!
                    }), id: \.id) { chapter in
                        ComicDetailListItem(chapter: chapter, currChapter: $currChapter)
                        Divider()
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
                .fullScreenCover(item: $currChapter, content: { currChapter in
                ComicView(chapter: currChapter, comic: comic, close: closeFullScreenCover)
            })
        }
            .onAppear() {
            viewContext.refreshAllObjects()
        }
    }
}
