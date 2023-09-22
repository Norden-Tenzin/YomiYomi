//
//  ComicDetailListItem.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/8/23.
//

import SwiftUI

struct ComicDetailListItem: View {
    @Environment(\.colorScheme) var currentMode
    @Binding var currChapter: Chapter?
    var chapter: Chapter

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
                    Text("Page \(chapter.currPageNumber + 1)")
                }
            }
                .foregroundStyle(.secondary)
                .font(.system(size: 12))
        }
            .foregroundStyle((chapter.currPageNumber + 1) == chapter.totalPageNumber ? .secondary : .primary)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
