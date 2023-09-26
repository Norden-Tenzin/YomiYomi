//
//  OLD.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/26/23.
//

import Foundation


//
//struct PagerView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Binding var chapter: Chapter
//    @Binding var pageObj: PageClass
//    @Binding var pages: [String]
//    @Binding var pageNumber: Double
//    @State var saveTimer: Timer? = nil
//    @State var loadTimer: Timer? = nil
//    let prev: Chapter?
//    let next: Chapter?
//
//    var body: some View {
//        Pager(
//            page: pageObj.page,
////            data: ["prev:\(prev?.getName() ?? "nil")"] + pages + ["next:\(next?.getName() ?? "nil")"],
//            data: pages,
//            id: \.self,
//            content: { page in
////                TODO: - Add chapter indicators
////                if page.contains("prev") {
////                    VStack {
////                        Text("Previous: \(prev?.getName() ?? "nil")")
////                        Text("Current: \(chapter.getName())")
////                    }
////                } else if page.contains("next") {
////                    VStack {
////                        Text("Previous: \(next?.getName() ?? "nil")")
////                        Text("Current: \(chapter.getName())")
////                    }
////                }
////                else {
//                PageView(pageNumber: $pageNumber, saveTimer: $saveTimer, loadTimer: $loadTimer, pageStringImage: page, viewContext: viewContext, pages: pages, offset: 4, chapter: chapter)
////                }
//            }
//        )
//            .contentLoadingPolicy(.lazy(recyclingRatio: 7))
//            .allowsDragging(true)
//            .onPageWillChange { index in
//            DispatchQueue.main.async {
//                print(pageNumber)
//                pageNumber = Double(index)
//            }
//        }
//    }
//}

//
//struct nestedPager: View {
//    @Binding var pageOffset: Double
//    @Binding var page: Page
//    let nestedData: [Int]
//    let nestedPagerModel: Page
//    let index: Int
//
//    var body: some View {
//        VStack {
//            Text("Parent page: \(index)")
//                .font(.system(size: 22))
//                .bold()
//                .padding(20)
//            Spacer()
//            Pager(page: nestedPagerModel,
//                data: self.nestedData,
//                id: \.self) { page in
//                self.pageView(page)
//            }
//                .bounces(true)
//                .onDraggingBegan({
//                print("Dragging Began")
//            })
//                .onDraggingChanged { increment in
//                withAnimation {
//                    if nestedPagerModel.index == self.nestedData.count - 1, increment > 0 {
////                            index is at end so go to next page
//                        pageOffset = increment
//                    } else if nestedPagerModel.index == 0, increment < 0 {
////                            index is at begining so go to prev page
//                        pageOffset = increment
//                    }
//                }
//            }
//                .onDraggingEnded {
//                guard pageOffset != 0 else { return }
//                let sign = Int(pageOffset / abs(pageOffset))
//                let increment: Int = (abs(pageOffset) > 0.33 ? 1 : 0) * sign
//                withAnimation {
//                    pageOffset = 0
//                    let newIndex = page.index + increment
//                    page.update(.new(index: newIndex))
//                }
//            }
//                .itemSpacing(10)
//                .itemAspectRatio(0.8, alignment: .end)
//                .padding(8)
//        }
//    }
//
//    func pageView(_ page: Int) -> some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.yellow)
//            Text("Nested page: \(page)")
//                .bold()
//        }
//            .cornerRadius(5)
//            .shadow(radius: 5)
//    }
//}
