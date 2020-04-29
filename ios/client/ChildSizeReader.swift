//
//  ChildSizeReader.swift
//  client
//
//  Created by Nadir Muzaffar on 4/28/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack(alignment: .leading) {
            content()
                .border(Color.blue)
                .background(
                    GeometryReader { proxy in
                        Rectangle()
                            .size(width: proxy.size.width, height: proxy.size.height)
                            .fill(Color.clear)
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
            .offset(x: 0, y: 0)
        }
        .border(Color.red)
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

