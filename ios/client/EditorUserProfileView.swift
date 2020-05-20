//
//  UserProfileView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Combine

struct EditorUserProfileView: View {
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var userState: UserState
    
    @EnvironmentObject var userAPI: UserAPI
    
    @State private var givenName: String = ""
    @State private var familyName: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State var image: Image? = nil

    @State private var userCancellable: AnyCancellable? = nil
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func save() {
        let user = User(id: nil, externalUserId: nil, email: nil, givenName: givenName, familyName: familyName)
        
        userAPI.patchMe(user: user) { _ in
            self.routeState.editUserProfile = false
            self.userState.userInfo = user
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .center) {
                    Button(action: { self.routeState.editUserProfile = false }) {
                        Text("Cancel")
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: { self.save() }) {
                        Text("Save").fontWeight(.semibold)
                    }
                    .padding(.trailing)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: { self.showingImagePicker = true }) {
                        if image != nil {
                            image!
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .frame(height: 100)
                        } else {
                            UserIconShape()
                                .fill(Color.gray)
                                .padding(30)
                                .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: 100)
                                .padding([.leading, .trailing])
                        }
                    }
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }
                    
                    Spacer()
                }
                .padding([.bottom])
                .background(Color.white)
                
                Divider()
            }
            
            Form {
                Section(header: Text("General")) {
                    HStack {
                        TextField("First Name", text: $givenName)
                    }
                    
                    HStack {
                        TextField("Last Name", text: $familyName)
                    }
                }
            }
        }
        .background(Color.white)
        .onAppear {
            UITableView.appearance().separatorColor = .separator
            self.userCancellable = self.userState.$userInfo.sink { user in
                self.givenName = user.givenName ?? ""
                self.familyName = user.familyName ?? ""
            }
            
            self.givenName = self.userState.userInfo.givenName ?? ""
            self.familyName = self.userState.userInfo.familyName ?? ""
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditorUserProfileView()
    }
}
