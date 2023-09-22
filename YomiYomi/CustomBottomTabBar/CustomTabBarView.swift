//
//  CustomTabBarView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/18/23.
//

import SwiftUI

struct CustomTabBarView: View {
    @State var tabs: [CustomTabBarItem]
    @Binding var selection: CustomTabBarItem;
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                    switchToTab(tab: tab)
                }
            }
        }
            .font(.system(size: 25))
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 50)
            .cornerRadius(10)
            .padding(.horizontal)
            .background(.regularMaterial)
    }
}

extension CustomTabBarView {
    private func tabView(tab: CustomTabBarItem) -> some View {
        VStack {
            Image(systemName: tab.img
            )
            Text(tab.text)
                .font(.system(size: 10))
        }
//            .foregroundColor(selection.text == tab.text ? Color.primary : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
//            .scaleEffect(selection.text == tab.text ? 1.1 : 1)
    }

    private func switchToTab(tab: CustomTabBarItem) {
        withAnimation(.easeInOut) {
            self.selection = tab
        }
    }
}

struct CustomTabBarItem: Hashable {
    let img: String;
    var text: String;
}

struct CustomTabBarView_Previews: PreviewProvider {
    static let tabs = [CustomTabBarItem(img: "books.vertical.fill", text: "library"), CustomTabBarItem(img: "gear", text: "settings")]
    @State static var selection = CustomTabBarItem(img: "books.vertical.fill", text: "Library")
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: $selection)
        }
    }
}
