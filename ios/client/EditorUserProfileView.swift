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
    @State var uiImage: UIImage? = nil

    @State private var userCancellable: AnyCancellable? = nil
    
    func save() {
        let user = User(id: nil, externalUserId: nil, email: nil, givenName: givenName, familyName: familyName)
        
        userAPI.patchMeUser(user: user) { _ in
            self.routeState.editUserProfile = false
            self.userState.userInfo = user
        }
        
        guard let data = uiImage?.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // TODO: before we switch the view check both requests succeeded
        userAPI.updateMeUserImage(data: data) {
            self.routeState.editUserProfile = false
        }
    }
    
    func loadImage(for userID: Int) {
        self.userAPI.getImage(for: userID) { data in
            guard let uiImage = UIImage(data: data) else {
                print("Couldn't load image!")
                return
            }
            self.image = Image(uiImage: uiImage)
        }
    }
    
    var disableSaveButton: Bool {
        if givenName != userState.userInfo.givenName {
            return false
        }
        
        if familyName != userState.userInfo.familyName {
            return false
        }
        
        if image != nil {
            return false
        }
        
        return true
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .separator
        UITableView.appearance().backgroundColor = .systemGroupedBackground
        
        return VStack(spacing: 0) {
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
                    .disabled(disableSaveButton)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: { self.showingImagePicker = true }) {
                        if image != nil {
                            image!
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .padding(.all, 0)
                                .frame(height: 130)
                        } else {
                            UserIconShape()
                                .fill(Color.gray)
                                .padding(50)
                                .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: 130)
                                .padding([.leading, .trailing])
                        }
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
            self.userCancellable = self.userState.$userInfo.sink { user in
                self.givenName = user.givenName ?? ""
                self.familyName = user.familyName ?? ""
                
                if self.userState.userInfo.id != user.id && user.id != nil {
                    self.loadImage(for: user.id!)
                }
            }
            
            self.givenName = self.userState.userInfo.givenName ?? ""
            self.familyName = self.userState.userInfo.familyName ?? ""
            
            guard let userID = self.userState.userInfo.id else {
                print("Couldn't get userID in order to load image")
                return
            }
            
            self.loadImage(for: userID)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.uiImage = image
                self.image = Image(uiImage: image)
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditorUserProfileView()
    }
}
