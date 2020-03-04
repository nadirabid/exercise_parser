//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Combine

let baseURL = "http://localhost:1234"
let appColor: Color = Color(red: 224 / 255, green: 84 / 255, blue: 9 / 255)

struct FeedView: View {
    @State private var newActivity = false
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil

    func showNewActivity() {
        self.newActivity = true
    }
    
    func getFeedData() {
        self.feedDataPublisher = URLSession.shared.dataTaskPublisher(for: URL(string: "\(baseURL)/workout")!)
            .map{ response in response.data }
            .decode(type: PaginatedResponse<Workout>.self, decoder: JSONDecoder())
            .replaceError(with: PaginatedResponse<Workout>(page: 0, count: 0, pages: 0, results: []))
            .sink(receiveValue: { response in self.feedData = response })
    }
    
    var body: some View {
        return VStack {
            if !newActivity {
                if self.feedData != nil {
                    ScrollView {
                        ForEach(self.feedData!.results) { workout in
                            ContentView(workout: workout)
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("You have nothing in your feed!")
                        Spacer()
                    }
                    
                    Spacer()
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
        .onAppear {
            self.getFeedData()
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
#endif
