//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var route: RouteState
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
    
    func getFeedData() {
        self.feedDataPublisher = URLSession
            .shared
            .dataTaskPublisher(for: URL(string: "\(baseURL)/workout")!)
            .map{ response in response.data }
            .decode(type: PaginatedResponse<Workout>.self, decoder: JSONDecoder())
            .replaceError(with: PaginatedResponse<Workout>(page: 0, count: 0, pages: 0, results: []))
            .sink(receiveValue: { response in self.feedData = response })
    }
    
    func getLocalFeedData() {
        self.feedData = localFeedData
    }
        
    var body: some View {
        return VStack {
            if self.feedData != nil && self.feedData?.count ?? 0 > 0  {
                ScrollView {
                    ForEach(self.feedData!.results) { workout in
                        WorkoutView(workout: workout)
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
        }
        .onAppear(){
            self.getFeedData()
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(WorkoutEditorState())
            .environmentObject(RouteState(current: .feed))
    }
}
#endif
