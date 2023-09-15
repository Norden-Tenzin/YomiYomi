//
//  ComicDetailListItem.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/8/23.
//

import SwiftUI

struct ComicDetailListItem: View {
    var chapter: Chapter
    @Binding var currChapter: Chapter?

    var body: some View {
        VStack(alignment: .leading) {
            Text(chapter.name!)
                .lineLimit(1)
                .onTapGesture {
                currChapter = chapter
            }
                .padding(.bottom, 2.5)
            HStack {
                Text("\(Date.now.formatted(date: .numeric, time: .omitted))")
                if chapter.currPageNumber > 0 && (chapter.currPageNumber + 1) != chapter.totalPageNumber {
                    Image(systemName: "circlebadge.fill")
                        .font(.system(size: 5))
                        .foregroundStyle(Color.gray)
                    Text("Page \(chapter.currPageNumber + 1)")
                }
            }
                .foregroundStyle(.gray)
                .font(.system(size: 12))
        }
            .foregroundStyle((chapter.currPageNumber + 1) == chapter.totalPageNumber ? .gray : .white)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
