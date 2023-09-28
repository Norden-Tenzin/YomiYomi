//
//  Card.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI
import CoreData

struct Card: View {
    @State var imageLoaded = false
    @State private var currChapter: Chapter?
    @State var isPopoverActive: Bool = false
    var comic: Comic

    var body: some View {
        NavigationLink(destination: ComicDetailView(comic: comic),
            label: {
                ZStack {
                    if imageLoaded {
                        ComicImage(comic: comic)
                    } else {
                        Color(uiColor: UIColor.random)
                            .aspectRatio(5.1 / 7.2, contentMode: .fill)
                    }
                    Rectangle().fill(
                        Gradient(stops: [
                                .init(color: .clear, location: 0.5),
                                .init(color: .black, location: 1.40)
                            ]
                        )
                    )
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(comic.name ?? "Unknown")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color.white)
                            .padding(.all, 10)
                            .shadow(color: Color.black, radius: 5)
                    }
                }
                    .background(Color.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8)
            }
        )
            .onAppear() {
            Task.detached {
                if comic.cover == "" {
                    let currChapter = Array(comic.chapters as! Set<Chapter>).sorted { lhs, rhs in
                        lhs.name! < rhs.name!
                    }
                    if currChapter != [] {
                        let cover = setCoverToFirstPage(chapterName: currChapter.first!.name!, originalLocation: currChapter.first!.chapterLocation!)
                        DispatchQueue.main.async {
                            comic.cover = cover
                            imageLoaded = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        imageLoaded = true
                    }
                }
            }
        }
    }

    struct ComicImage: View {
        var comic: Comic
        var body: some View {
            let image: UIImage? = UIImage(contentsOfFile: getDirectoryInDocuments(of: comic.cover!).path)
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(5.1 / 7.2, contentMode: .fit)
                    .aspectRatio(contentMode: .fill)
            } else {
                Color(uiColor: UIColor.random)
                    .aspectRatio(5.1 / 7.2, contentMode: .fill)
            }
        }
    }
}
