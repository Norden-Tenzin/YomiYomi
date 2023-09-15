//
//  Card.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI

struct Card: View {
    let comic: Comic
    @State var imageLoaded = false

    var body: some View {
        NavigationLink(destination: ComicDetailView(comic: comic),
            label: {
                ZStack {
                    if imageLoaded {
                        ComicImage(comic: comic)
                    } else {
                        Color.white
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
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
        )
            .onAppear() {
            DispatchQueue(label: "com.yomiyomi.background", attributes: .concurrent).async {
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
        let comic: Comic
        var body: some View {
            let image: UIImage? = UIImage(contentsOfFile: getDirectoryInDocuments(of: comic.cover!).path)
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(5.1 / 7.2, contentMode: .fit)
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.white
                    .aspectRatio(5.1 / 7.2, contentMode: .fill)
            }
        }
    }
}

/**
 * it unzips the comic to temp location then moves the cover image to doc where cover is stored
 *
 * @param chapterName name of the chapter to retrieve the cover
 * @param originalLocation location of the chapter to retrieve the cover
 * @return  String location for the cover
 **/
func setCoverToFirstPage(chapterName: String, originalLocation: String) -> String {
    let tempLocation = getDirectoryInDocuments(of: COMIC_DATA_LOCATION_NAME + "/temp/").path
    let coverLocation = COMIC_DATA_LOCATION_NAME + "/Covers/\(chapterName)"
    createDirectoryInDocuments(dirName: COMIC_DATA_LOCATION_NAME + "/Covers/\(chapterName)")
    createDirectoryInDocuments(dirName: COMIC_DATA_LOCATION_NAME + "/temp/\(chapterName)/")
    if !FileManager.default.fileExists(atPath: getDirectoryInDocuments(of: coverLocation).path + "/cover.jpg") {
        unzipCBZFile(at: getDirectoryInDocuments(of: originalLocation).path, to: tempLocation + "\(chapterName)/")
        let pages = getComicPages(at: tempLocation + "\(chapterName)/")
        do {
            if FileManager.default.fileExists(atPath: "\(tempLocation)\(chapterName)/\(pages[0])") {
                try FileManager.default.moveItem(at: URL(filePath: "\(tempLocation)\(chapterName)/\(pages[0])"), to: URL(filePath: getDirectoryInDocuments(of: coverLocation).path + "/cover.jpg"))
            }
        } catch {
            print ("Error moving file: \(error)")
        }
        do {
            if FileManager.default.fileExists(atPath: "\(tempLocation)\(chapterName)/") {
                try FileManager.default.removeItem(atPath: "\(tempLocation)\(chapterName)/")
            }
        } catch {
            print ("Error removing file: \(error)")
        }
    }
    return coverLocation + "/cover.jpg"
}
