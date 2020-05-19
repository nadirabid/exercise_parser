//
//  UserProfileView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct EditorUserProfileView: View {
    @State var givenName: String = ""
    @State var familyName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .center) {
                    Text("Cancel").padding(.leading)
                    
                    Spacer()
                    
                    Text("Save").padding(.trailing)
                }
                
                HStack {
                    Spacer()
                    
                    UserIconShape()
                        .fill(Color.gray)
                        .padding(30)
                        .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: 100)
                        .padding([.leading, .trailing])
                    
                    Spacer()
                }
                .padding([.bottom])
                .background(Color.white)
                
                Divider()
            }
            .background(Color.white)
            
            Form {
                Section(header: Text("General")) {
                    TextField("First Name", text: $givenName)
                    
                    TextField("Last Name", text: $familyName)
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditorUserProfileView()
    }
}
