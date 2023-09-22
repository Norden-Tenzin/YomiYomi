//
//  TabView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/6/23.
//

import Foundation
import SwiftUI

struct Tab {
    var icon: Image?
    var title: String
}

struct Tabs: View {
    var fixed = true
    var tabs: [Tab]
    var geoWidth: CGFloat
    @Binding var selectedTab: Int
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(0 ..< tabs.count, id: \.self) { row in
                            Button(action: {
                                withAnimation {
                                    selectedTab = row
                                }
                            }, label: {
                                    VStack(spacing: 0) {
                                        ZStack {
                                            Color.gray
                                            HStack {
                                                // Image
                                                //                                            AnyView(tabs[row].icon)
                                                //                                                .foregroundColor(.white)
                                                //                                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                                                // Text
                                                Text(tabs[row].title)
                                                    .font(Font.system(size: 14, weight: .semibold))
//                                                    .foregroundColor(Color.white)
                                                //                                                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                            }
                                                .frame(width: fixed ? (geoWidth / CGFloat(tabs.count)) : .none, height: 40)
                                        }
                                        // Bar Indicator
                                        Rectangle().fill(selectedTab == row ? Color.white : Color.clear)
                                            .frame(height: 3)
                                    }.fixedSize()
                                })
                                .accentColor(Color.white)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                        .onChange(of: selectedTab, { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue)
                        }
                    })
//                        .onChange(of: selectedTab) { target in
//                        withAnimation {
//                            proxy.scrollTo(target)
//                        }
//                    }
                }
            }
        }
            .frame(height: 55)
            .onAppear(perform: {
            UIScrollView.appearance().backgroundColor = UIColor(Color.black)
            UIScrollView.appearance().bounces = fixed ? false : true
        })
            .onDisappear(perform: {
            UIScrollView.appearance().bounces = true
        })
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    @State private var selectedTab: Int = 0
//
//    let tabs: [Tab] = [
//            .init(icon: Image(systemName: "music.note"), title: "Music"),
//            .init(icon: Image(systemName: "film.fill"), title: "Movies"),
//            .init(icon: Image(systemName: "book.fill"), title: "Books")
//    ]
//
//    static var previews: some View {
//        Tabs(tab: tabs, geoWidth: )
//    }
//}

