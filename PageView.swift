//
//  PageView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/10/23.
//

import SwiftUI
import SwiftUIPager
import CoreData
import Combine

struct PagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var chapter: Chapter
    @Binding var pageObj: PageClass
    @Binding var pages: [String]
    @Binding var pageNumber: Double
    @State var saveTimer: Timer? = nil
    @State var loadTimer: Timer? = nil

    var body: some View {
        Pager(
            page: pageObj.page,
            data: pages,
            id: \.self,
            content: { page in
                PageView(pageNumber: $pageNumber, saveTimer: $saveTimer, loadTimer: $loadTimer, pageStringImage: page, viewContext: viewContext, pages: pages, offset: 4, chapter: chapter)
            }
        )
            .contentLoadingPolicy(.lazy(recyclingRatio: 7))
            .allowsDragging(true)
            .onPageWillChange { index in
            DispatchQueue.main.async {
                pageNumber = Double(index)
            }
        }
    }
}

struct PageView: View {
    @Binding var pageNumber: Double
    @Binding var saveTimer: Timer?
    @Binding var loadTimer: Timer?
    @State var loaded: Bool = false
    @State var pagePos: Int = 0
    @State var pageImage: UIImage? = nil
    var pageStringImage: String
    var viewContext: NSManagedObjectContext
    var pages: [String]
    let offset: Int
    let chapter: Chapter

    var body: some View {
        Group {
            if loaded && pageImage != nil {
                ZoomableContainer {
                    Image(uiImage: pageImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                    .onDisappear() {
                    setLoaded(pageNumber: pageNumber)
                }
            } else {
                ProgressView()
                    .onAppear() {
                    loadComic()
                }
            }
        }
            .onReceive(Just(pageNumber)) { newValue in
            if Int(newValue) == pagePos {
                updateComic(newIndex: Int(newValue))
            }
        }
    }

    func loadComic() {
        DispatchQueue(label: "com.yomiyomi.background", attributes: .concurrent).async {
            let pos = pages.firstIndex(of: pageStringImage)!
            let uIImage = UIImage(contentsOfFile: pageStringImage)
            DispatchQueue.main.async {
                if pageImage == nil {
                    pageImage = uIImage
                }
            }
            pagePos = pos
            if (Int(pageNumber) - offset) < pagePos && pagePos < (Int(pageNumber) + offset) {
                loaded = true
            }
        }
    }

    func updateComic(newIndex: Int) {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [self] timer in
            DispatchQueue.global(qos: .background).async {
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateContext.perform {
                    do {
                        let fetchRequest = NSFetchRequest<Chapter>(entityName: "Chapter")
                        fetchRequest.predicate = NSPredicate(format: "id == %@", chapter.id! as CVarArg)
                        if let object = try viewContext.fetch(fetchRequest).first {
                            object.setValue(newIndex, forKey: "currPageNumber")
                        }
                        try viewContext.save()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }

    func setLoaded(pageNumber: Double) {
        DispatchQueue(label: "com.yomiyomi.background", attributes: .concurrent).async {
            if (Int(pageNumber) - offset) < pagePos && pagePos < (Int(pageNumber) + offset) {
                let uIImage = UIImage(contentsOfFile: pageStringImage)
                DispatchQueue.main.async {
                    loaded = true
                    pageImage = uIImage
                }
            } else {
                DispatchQueue.main.async {
                    loaded = false
                    pageImage = nil
                }
            }
        }
    }
}
