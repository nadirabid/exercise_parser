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
    @EnvironmentObject var userState: UserState
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
    
    func getFeedData() {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        let url = "\(baseURL)/workout"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    self.feedData = try! JSONDecoder().decode(PaginatedResponse<Workout>.self, from: data!)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
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
            .environmentObject(UserState())
    }
}
#endif
