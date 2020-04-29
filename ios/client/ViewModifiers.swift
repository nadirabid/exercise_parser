//
//  ViewModifiers.swift
//  client
//
//  Created by Nadir Muzaffar on 4/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import SwiftUI

struct AdaptsToSoftwareKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    @State var isKeyboardDisplayed = false
    
    @State private var showKeyBoardCancellable: AnyCancellable? = nil
    @State private var hideKeyBoardCancellable: AnyCancellable? = nil
    
    func body(content: Content) -> some View {
        return content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(isKeyboardDisplayed ? [.bottom] : [])
            .onAppear(perform: subscribeToKeyboardEvents)
    }
    
    private func subscribeToKeyboardEvents() {
        let speed = 2.2
        
        self.showKeyBoardCancellable = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification
        ).compactMap { notification in
            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        }.map { rect in
            rect.height
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { (height) in
            self.isKeyboardDisplayed = true
            
            withAnimation(Animation.easeInOut.speed(speed)) {
                self.currentHeight = height
            }
        })
        
        self.hideKeyBoardCancellable = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification
        ).compactMap { notification in
            CGFloat.zero
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { (height) in
            self.isKeyboardDisplayed = false
            
            withAnimation(Animation.easeInOut.speed(speed)) {
                self.currentHeight = height
            }
        })
    }
}

public struct DeletableViewModifier: ViewModifier {
    var disable: Bool
    var onClick: () -> Void = {}
    
    @State private var dragOffset = CGFloat.zero
    @State private var prevOffset = CGFloat.zero
    
    public func body(content: Content) -> some View {
        return ZStack {
            GeometryReader { (geometry: GeometryProxy) in
                HStack {
                    Text("Delete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .padding(.leading)
                        .fixedSize()
                    
                    Spacer()
                }
                    .frame(width: abs(self.dragOffset), height: geometry.size.height)
                    .background(Color.red)
                    .offset(x: geometry.size.width + self.dragOffset)
                    .animation(
                        (self.dragOffset == CGFloat.zero || self.dragOffset == -140) ? .spring() : .none
                    )
                    .onTapGesture {
                        DispatchQueue.main.async {
                            self.onClick()
                        }
                    }
            }

            content
                .animation(
                    !self.disable && (dragOffset == CGFloat.zero || dragOffset == -140) ? .spring() : .none
                )
                .offset(x: self.dragOffset)
                .gesture(DragGesture()
                    .onChanged({ value in
                        let delta = value.translation.width - self.prevOffset
                        let offset = self.dragOffset + delta
                        
                        self.prevOffset = value.translation.width

                        if !self.disable && offset < 0 {
                            self.dragOffset = max(offset, -140)
                        }
                    })
                    .onEnded({ value in
                        if value.translation.width > -90 {
                            self.dragOffset = 0.0
                        } else {
                            self.dragOffset = -140
                        }
                    })
                )
                .highPriorityGesture(TapGesture()) // this allows scrollview to work
        }
    }
}
