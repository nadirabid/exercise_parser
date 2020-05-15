//
//  HelpView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/14/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("About")
                    .font(.title)
                    .padding([.leading, .trailing, .top])
                
                Text("The application is currently in beta. It's being designed and developed by fitness enthusiasts.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding()
                
                Text("Join the beta if you want this application developed for you.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding()
            }
            
            
            VStack(alignment: .leading) {
                Text("How it works")
                    .font(.title)
                    .padding([.leading, .trailing, .top])
                
                Text("Type in the exercise name with reps, sets, distance,  time.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding()
                
                Text("The only requirement is that each entry be a single exercise. We'll figure out the rest.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding()
                
                Text("Examples:")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding()
                
                Text("3x3 tricep extensions - 45 lbs")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .padding([.leading, .trailing])
                    .padding(.bottom, 4)
                
                Text("Rowing 4km in 5mins")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .padding([.leading, .trailing, .bottom])
            }
            
            VStack(alignment: .leading) {
                Text("Metrics")
                    .font(.title)
                    .padding([.leading, .trailing, .top])
                
                Text("We're working on metrics but we'd need and love to know what metrics are useful to you.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .border(Color.blue)
    }
}
