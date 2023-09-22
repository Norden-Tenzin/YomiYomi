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
