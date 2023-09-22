//
//  TabBarItemPreferenceKey.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/18/23.
//

import Foundation
import SwiftUI

struct TabBarItemPreferenceKey: PreferenceKey {
    static var defaultValue: [CustomTabBarItem] = []

    static func reduce(value: inout [CustomTabBarItem], nextValue: () -> [CustomTabBarItem]) {
        value += nextValue()
    }
}

struct TabBarItemViewModifier: ViewModifier {
    let tab: CustomTabBarItem
    @Binding var selection: CustomTabBarItem
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: TabBarItemPreferenceKey.self, value: [tab])
    }
}

extension View {
    func tabBarItem(tab: CustomTabBarItem, selection: Binding<CustomTabBarItem>) -> some View {
        self
            .modifier(TabBarItemViewModifier(tab: tab, selection: selection))
    }
}
