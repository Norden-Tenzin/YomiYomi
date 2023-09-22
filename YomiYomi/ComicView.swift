//
//  ComicView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI
import SwiftUIPager
import CoreData

class PageClass: ObservableObject {
    @Published var page: Page = Page.withIndex(0)
}

struct ComicView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var pageObj: PageClass = PageClass()
    @State var pages: [String] = []
    @State var pageNumber: Double = 0
    @State var sliderIndex: Double = 0
    @State var sliderMax: Double = 0

    @State var isOverlayActive: Bool = false
    @State var loaded: Bool = false
    @State var tempLocation: String = ""
    @State var deleteLocation: String = ""

    @State var chapter: Chapter
    @State var prev: Chapter? = nil
    @State var next: Chapter? = nil
    var comic: Comic
    var close: (String) -> Void

    private func sliderChanged(to newValue: Double) {
        DispatchQueue.main.async {
            pageNumber = newValue
            //        let roundedValue = Int(pageNumber)
            //        updateComic(newIndex: roundedValue, viewContext: viewContext, currChapter: chapter)
            pageObj.page.update(Page.Update.new(index: Int(pageNumber)))
        }
    }

    func openChapter(currChapter: Chapter) {
        loaded = false
        print("ONAPPREAR RAN")
        DispatchQueue(label: "com.yomiyomi.background", attributes: .concurrent).async {
            let comicName = comic.name!
            let chapterName = currChapter.name!
            print(currChapter.toString())
            tempLocation = getDirectoryInDocuments(of: COMIC_DATA_LOCATION_NAME).path + "/temp/\(comicName)/\(chapterName)/"
            createDirectoryInDocuments(dirName: COMIC_DATA_LOCATION_NAME + "/temp/\(comicName)/\(chapterName)/")
            deleteLocation = getDirectoryInDocuments(of: COMIC_DATA_LOCATION_NAME).path + "/temp/\(comicName)/"

//            MARK: -   gets the pages and sets the slider values
            if FileManager.default.fileExists(atPath: getDirectoryInDocuments(of: currChapter.chapterLocation!).path) {
                unzipCBZFile(at: getDirectoryInDocuments(of: currChapter.chapterLocation!).path, to: tempLocation)
                currChapter.pages = getComicPages(at: tempLocation)
                func getAllPages(chapter: Chapter) -> [String] {
                    var res: [String] = []
                    for pageLoc in chapter.pages! {
                        res.append(tempLocation + "/" + pageLoc)
                    }
                    return res
                }

                let tempPages = getAllPages(chapter: currChapter)
                DispatchQueue.main.async {
                    sliderIndex = Double(currChapter.currPageNumber)
                    pageObj.page.index = Int(currChapter.currPageNumber)
                    pages = tempPages
                    currChapter.totalPageNumber = Int64(pages.count)
                    pageNumber = Double(currChapter.currPageNumber)
                    sliderMax = max(Double(pages.count) - 1, 1)
                    loaded = true
                }
            } else {
                close(deleteLocation)
            }

//            MARK: -   SETS NEW NEXT AND PREV CHAPTERS
            let chapterArr = (comic.chapters!.allObjects as! [Chapter]).sorted { c1, c2 in
                c1.name! < c2.name!
            }
            let chapterIndex: Int? = chapterArr.firstIndex(of: chapter)
            if chapterIndex != nil {
                let prevIndex = chapterIndex! - 1
                if 0 <= prevIndex && prevIndex < chapterArr.count {
                    prev = chapterArr[prevIndex]
                } else {
                    prev = nil
                }

                let nextIndex = chapterIndex! + 1
                if 0 <= nextIndex && nextIndex < chapterArr.count {
                    next = chapterArr[nextIndex]
                } else {
                    next = nil
                }
            }
        }
    }

    var body: some View {
        if loaded == false {
            ProgressView()
                .onAppear {
                openChapter(currChapter: chapter)
            }
        } else {
            ZStack {
                PagerView(chapter: $chapter, pageObj: $pageObj, pages: $pages, pageNumber: $pageNumber)
                    .gesture(TapGesture(count: 1).onEnded({ void in
                        isOverlayActive.toggle()
                    }))
                VStack {
//                    MARK: TOP BAR
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .padding([.top, .leading, .bottom], 15)
                            .padding(.trailing, 5)
                            .onTapGesture {
                            close(deleteLocation)
                        }
                        VStack(alignment: .leading) {
                            Text(chapter.name!)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                            Text(comic.name!)
                                .font(.system(size: 16))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                        .background(Color.gray)
                    Spacer()
//                    MARK: SCROLL
                    HStack {
                        Button {
//                            MARK: -   TODO go prev if exist
                            chapter = prev!
                            print(chapter.toString())
                            openChapter(currChapter: prev!)
                        } label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color.gray)
                                    .frame(width: 50)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .bold))
                                    .padding([.top, .leading, .bottom], 10)
                                    .padding(.trailing, 10)
                            }
                        }.disabled(prev == nil)
                        HStack {
                            Text("\(Int(pageNumber) + 1)")
                                .frame(maxWidth: 40)
                            Slider(
                                value: $sliderIndex,
                                in: 0...sliderMax,
                                step: 1)
                                .onChange(of: sliderIndex) { oldValue, newValue in
                                sliderChanged(to: newValue)
                            }
                            Text("\(chapter.totalPageNumber)")
                                .frame(maxWidth: 40)
                        }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.gray)
                            .cornerRadius(30)
                        Button {
//                            MARK: -   TODO go next if exist
                            chapter = next!
                            print(chapter.toString())
                            openChapter(currChapter: next!)
                        } label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color.gray)
                                    .frame(width: 50)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                                    .padding([.top, .trailing, .bottom], 10)
                                    .padding(.leading, 10)
                            }
                        }.disabled(next == nil)
                    }
                        .padding(.horizontal, 10)
//                    MARK: -   BOTTTOM BAR
                    HStack {
                        Spacer()
                        Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                            .font(.system(size: 25))
                        Spacer()
                        Image(systemName: "crop")
                            .font(.system(size: 25))
                        Spacer()
                        Image(systemName: "arrow.turn.up.forward.iphone")
                            .font(.system(size: 25))
                        Spacer()
                        Image(systemName: "gear")
                            .font(.system(size: 25))
                        Spacer()
                    }
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        .background(Color.gray)
                        .padding(.top, 5)
                }
                    .opacity(isOverlayActive ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.25), value: isOverlayActive)
            }
        }
    }
}
