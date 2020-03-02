//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

let appColor: Color = Color(red: 224 / 255, green: 84 / 255, blue: 9 / 255)

struct FeedView: View {
    @State private var newActivity = false

    func showNewActivity() {
        self.newActivity = true
    }
    
    var body: some View {
         VStack {
            if !newActivity {
                ScrollView {
                    ContentView()
                    ContentView()
                    ContentView()
                }
                
                Button(action: self.showNewActivity) {
                    ZStack {
                        Circle()
                            .stroke(appColor, lineWidth: 2)
                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .fill(appColor)
                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                            .frame(width: 20, height: 20)
                    }
                }
            } else {
                WorkoutEditorView()
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
