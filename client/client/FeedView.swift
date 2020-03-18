//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Alamofire
import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
        
    var body: some View {
        return VStack {
            if self.feedData != nil && self.feedData?.count ?? 0 > 0  {
                ScrollView {
                    ForEach(self.feedData!.results) { workout in
                        WorkoutView(workout: workout).background(Color.white)
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
            self.workoutAPI.getUserFeed { (response) in
                self.feedData = response
            }
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return FeedView()
            .environmentObject(WorkoutEditorState())
            .environmentObject(RouteState(current: .feed))
            .environmentObject(WorkoutPreviewProviderAPI(userState: UserState()))
    }
}
#endif
