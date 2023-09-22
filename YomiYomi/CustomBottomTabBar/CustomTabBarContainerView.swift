//
//  CustomTabBarContainerView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/18/23.
//

import SwiftUI

//let tabs = [TabBarItem(img: "magnifyingglass", text: "discover"), TabBarItem(img: "heart.fill", text: "heart")]

struct CustomTabBarContainerView <Content: View>: View {
    @Binding var selection: CustomTabBarItem
    @State var tabs: [CustomTabBarItem] = [CustomTabBarItem(img: "books.vertical.fill", text: "library"), CustomTabBarItem(img: "gear", text: "settings")]
    let content: Content

    init(selection: Binding<CustomTabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                CustomTabBarView(tabs: tabs, selection: $selection)
            }
        }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onPreferenceChange(TabBarItemPreferenceKey.self, perform: { value in
            self.tabs = value
        })
    }
}
//
//struct CustomTabBarContainerView_Previews: PreviewProvider {
//    static let tabs = [CustomTabBarItem(img: "magnifyingglass", text: "discover"), CustomTabBarItem(img: "heart.fill", text: "heart")]
//    static var previews: some View {
//        CustomTabBarContainerView(selection: .constant(tabs.first!), content: {
//                Color.red
//            })
//    }
//}
