//
//  PagerView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/15/23.
//

import SwiftUI
import SwiftUIPager
import CoreData

struct PagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var chapter: Chapter
    @State var chapters: FetchedResults<Chapter>
    @Binding var sliderIndex: Double
    @Binding var pageNumber: Double
    @State var saveTimer: Timer? = nil
    @State var loadTimer: Timer? = nil
    @State var multipleChapterLayerPage: PageClass
    @State var singleChapterLayerPage: PageClass
    @State var pageOffset: Double = 0

    var body: some View {
        Pager(page: self.multipleChapterLayerPage.page,
            data: self.chapters,
            id: \.id) { ch in
            if chapter == ch {
                SinglePagerView(pageOffset: $pageOffset, chapters: chapters, chapter: $chapter, sliderIndex: $sliderIndex, multipleChapterLayerPage: $multipleChapterLayerPage, singleChapterLayerPage: singleChapterLayerPage, pages: chapter.pages ?? [], pageNumber: $pageNumber, saveTimer: saveTimer, loadTimer: loadTimer)
            } else {
                ProgressView()
                    .onAppear() {
//                        set last chapter to unload
                    print("LOADING")
                    Task {
                        print(ch.name!)
//                        unzipChapter(currChapter: currChapter)
//                        let tempPages = getAllPages(chapter: currChapter)
//                        DispatchQueue.main.async {
//                            sliderIndex = Double(currChapter.currPageNumber)
//                            singleChapterLayerPage.page.update(.new(index: Int(currChapter.currPageNumber)))
//                            multipleChapterLayerPage.page.update(.new(index: chapters.firstIndex(of: chapter) ?? 0))
//                            currChapter.pages = tempPages
//                            pageNumber = Double(currChapter.currPageNumber)
//                            print(currChapter.totalPageNumber)
//                            print(currChapter.name ?? "unknown")
//                            loaded = true
//                            pagerLoaded = true
//                        }
                    }
                }
            }
        }
            .bounces(false)
            .pageOffset(pageOffset)
            .swipeInteractionArea(.allAvailable)
            .onAppear() {
            print("PAGER VIEW")
        }
            .onChange(of: chapter) { oldValue, newValue in
            print("CHAPTER CHANGE \(newValue.name!)")
        }
    }
}

struct SinglePagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var pageOffset: Double
    @State var chapters: FetchedResults<Chapter>
    @Binding var chapter: Chapter
    @Binding var sliderIndex: Double
    @Binding var multipleChapterLayerPage: PageClass
    @State var singleChapterLayerPage: PageClass
    @State var pages: [String]
    @Binding var pageNumber: Double
    @State var saveTimer: Timer? = nil
    @State var loadTimer: Timer? = nil

    var body: some View {
        Pager(
            page: singleChapterLayerPage.page,
            data: pages,
            id: \.self,
            content: { page in
//                TODO: -   Add chapter indicators
                PageView(pageNumber: $pageNumber, saveTimer: $saveTimer, loadTimer: $loadTimer, pageStringImage: page, viewContext: viewContext, pages: pages, offset: 4, chapter: chapter)
            }
        )
            .contentLoadingPolicy(.lazy(recyclingRatio: 7))
            .bounces(true)
            .allowsDragging(true)
            .onPageWillChange { index in
            pageNumber = Double(index)
            sliderIndex = Double(index)
        }
            .onDraggingChanged { increment in
            withAnimation {
                if singleChapterLayerPage.page.index == self.pages.count - 1, increment > 0 {
                    //                            index is at end so go to next page
                    pageOffset = increment
                } else if singleChapterLayerPage.page.index == 0, increment < 0 {
                    //                            index is at begining so go to prev page
                    pageOffset = increment
                }
            }
        }
            .onDraggingEnded {
            guard pageOffset != 0 else { return }
            let sign = Int(pageOffset / abs(pageOffset))
            let increment: Int = (abs(pageOffset) > 0.33 ? 1 : 0) * sign
            withAnimation {
                pageOffset = 0
                let newIndex = multipleChapterLayerPage.page.index + increment
                multipleChapterLayerPage.page.update(.new(index: newIndex))
//                chapter = chapters[multipleChapterLayerPage.page.index]
            }
        }
            .onAppear() {
            print("SINGLE PAGE VIEW")
        }
//            .onAppear() {
//            self.pageNumber = Double(chapter.currPageNumber)
//        }
    }
}
