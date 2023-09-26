//
//  PageView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/10/23.
//

import SwiftUI
import CoreData
import Combine

struct PageView: View {
    @Binding var pageNumber: Double
    @Binding var saveTimer: Timer?
    @Binding var loadTimer: Timer?
    @State var loaded: Bool = false
    @State var pagePos: Int = 0
    @State var pageImage: UIImage? = nil
    @State var comicUpdated: Bool = false
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
//                    .onDisappear() {
//                    setLoaded(pageNumber: pageNumber)
//                }
            } else {
                ProgressView()
                    .onAppear() {
                    loadComic()
                }
            }
        }
            .onChange(of: pageNumber, { oldValue, newValue in
            if Int(newValue) == pagePos && comicUpdated == false {
                saveTimer?.invalidate()
                saveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [self] timer in
                    updateComic(chapter: chapter, newIndex: newValue, viewContext: viewContext)
                }
                comicUpdated = true
            } else {
                comicUpdated = false
            }
        })
//            .onReceive(Just(pageNumber)) { newValue in
////            setLoaded(pageNumber: newValue)
////            print(newValue)
//            if Int(newValue) == pagePos && comicUpdated == false {
//                updateComic(newIndex: Int(newValue))
//                comicUpdated = true
//            } else {
//                comicUpdated = false
//            }
//        }
    }

    func loadComic() {
        Task.detached(priority: .background) {
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

    func setLoaded(pageNumber: Double) {
        DispatchQueue(label: "com.yomiyomi.background", attributes: .concurrent).async {
            if (Int(pageNumber) - offset) < pagePos && pagePos < (Int(pageNumber) + offset) {
                let uIImage = UIImage(contentsOfFile: pageStringImage)
                DispatchQueue.main.async {
                    pageImage = uIImage
                    loaded = true
                }
            } else {
                DispatchQueue.main.async {
                    pageImage = nil
                    loaded = false
                }
            }
        }
    }
}

func updateComic(chapter: Chapter, newIndex: Double, viewContext: NSManagedObjectContext) {
    Task.detached(priority: .background) {
        do {
            chapter.currPageNumber = Int64(newIndex)
            try viewContext.save()
        } catch {
            print("Error: \(error)")
        }
    }
}

