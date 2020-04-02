//
//  Utils.swift
//  client
//
//  Created by Nadir Muzaffar on 3/21/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

extension String: Error {}

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

func secondsToElapsedTimeString(_ seconds: Int) -> String {
    let seconds = seconds % 60
    let minutes = seconds / 60
    let hours = seconds / 60
    
    if hours == 0 {
        return "\(minutes)m \(seconds)s"
    }
    
    return "\(hours)h \(minutes)m"
}

func dateToWorkoutName(_ d: Date) -> String {
    return "\(d.weekdayString.capitalized) \(d.timeOfDayString.lowercased()) workout"
}
