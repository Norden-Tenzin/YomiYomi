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
    var comic: Comic

    @Binding var sliderIndex: Double
    @Binding var sliderMax: Double
    @Binding var pageNumber: Double

    @State var saveTimer: Timer? = nil
    @State var loadTimer: Timer? = nil

    @State var multipleChapterLayerPage: PageClass
    @State var singleChapterLayerPage: PageClass

    @State var outerPageOffset: Double = 0

    @State var chapterLoaded: Bool = false

    var body: some View {
        Pager(page: self.multipleChapterLayerPage.page,
            data: self.chapters,
            id: \.id) { ch in
            if chapter == ch {
                SinglePagerView(outerPageOffset: $outerPageOffset, chapters: chapters, chapter: $chapter, sliderIndex: $sliderIndex, sliderMax: $sliderMax, multipleChapterLayerPage: $multipleChapterLayerPage, singleChapterLayerPage: singleChapterLayerPage, pages: chapter.pages ?? [], pageNumber: $pageNumber, saveTimer: saveTimer, loadTimer: loadTimer)
            } else {
                ProgressView()
                    .onAppear() {
                    let currChapterIndex = chapters.firstIndex(of: chapter) ?? 0
                    let chaptersList: [Chapter] = chapters.map { ch in
                        return ch
                    }
                    let res = getItemsAroundIndex(chaptersList, index: currChapterIndex)
                    let prev = res.0
                    let next = res.1

                    if prev != nil {
                        Task(priority: .background) {
                            _ = unzipChapter(currChapter: prev!, comic: comic)
                            let tempPages = getAllPages(chapter: prev!, comic: comic)
                            prev!.pages = tempPages
                        }
                    }

                    if next != nil {
                        Task(priority: .background) {
                            _ = unzipChapter(currChapter: next!, comic: comic)
                            let tempPages = getAllPages(chapter: next!, comic: comic)
                            next!.pages = tempPages
                        }
                    }
                }
            }
        }
            .bounces(false)
            .pageOffset(outerPageOffset)
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
    @Binding var outerPageOffset: Double
    @State var innerPageOffset: Double = 0
    @State var chapters: FetchedResults<Chapter>
    @Binding var chapter: Chapter
    @Binding var sliderIndex: Double
    @Binding var sliderMax: Double
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
            .pageOffset(innerPageOffset)
            .allowsDragging(true)
            .onPageWillChange { index in
            print("INDEX: \(index)")
        }
            .onDraggingChanged { increment in
            withAnimation {
                if increment > 0 {
                    if singleChapterLayerPage.page.index == self.pages.count - 1 {
                        //                            index is at end so go to next page
                        outerPageOffset = increment
                    } else {
                        innerPageOffset = increment
                    }
                } else if increment < 0 {
                    if singleChapterLayerPage.page.index == 0 {
                        //                            index is at begining so go to prev page
                        outerPageOffset = increment
                    } else {
                        innerPageOffset = increment
                    }
                }
            }
        }
            .onDraggingEnded {
            if innerPageOffset != 0 {
                print("INNER PAGE OFFSET")
                let innersign = Int(innerPageOffset / abs(innerPageOffset))
                let innerincrement: Int = (abs(innerPageOffset) > 0.33 ? 1 : 0) * innersign
                print("INCREMENT: \(innerincrement)")
                Task {
                    withAnimation {
                        innerPageOffset = 0
                        let newIndex = singleChapterLayerPage.page.index + innerincrement
                        print("NEW INDEX: \(newIndex)")
                        singleChapterLayerPage.page.update(.new(index: newIndex))
                        pageNumber = Double(newIndex)
                        sliderIndex = Double(newIndex)
                    }
                }
            }
            if outerPageOffset != 0 {
                print("OUTER PAGE OFFSET")
                let sign = Int(outerPageOffset / abs(outerPageOffset))
                let increment: Int = (abs(outerPageOffset) > 0.33 ? 1 : 0) * sign
                withAnimation {
                    outerPageOffset = 0
                    let newIndex = multipleChapterLayerPage.page.index + increment
                    multipleChapterLayerPage.page.update(.new(index: newIndex))
                    chapter = chapters[multipleChapterLayerPage.page.index]
                    print(increment)
                    print(newIndex)
                    print(pageNumber)
                    if increment < 0 {
                        print("GOING PREV")
//                        go to prev if prev exists
                        if newIndex > -1 {
                            singleChapterLayerPage.page.update(.new(index: Int(chapter.totalPageNumber)))
                            sliderIndex = Double(chapter.totalPageNumber - 1)
                            sliderMax = Double(max(chapter.totalPageNumber - 1, 1))
                        }
                    } else if increment > 0 {
                        print("GOING NEXT")
//                        go to next if next exists
                        if newIndex < chapter.totalPageNumber {
                            singleChapterLayerPage.page.update(.new(index: 0))
                            sliderIndex = 0
                            sliderMax = Double(max(chapter.totalPageNumber - 1, 1))
                        }
                    }
                }
            }
        }
            .onAppear() {
            print("SINGLE PAGE VIEW")
        }
    }
}

func getItemsAroundIndex<T>(_ array: [T], index: Int) -> (previous: T?, next: T?) {
    guard index >= 0 && index < array.count else {
        fatalError("Index is out of range")
    }
    let previousItem: T? = index > 0 ? array[index - 1] : nil
    let nextItem: T? = index < array.count - 1 ? array[index + 1] : nil

    return (previousItem, nextItem)
}
