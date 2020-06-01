//
//  UserProfileView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Promises
import Combine

struct EditorUserProfileView: View {
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var userState: UserState
    
    @EnvironmentObject var userAPI: UserAPI
    
    // picker vars
    @State private var showBirthdatePicker = false
    @State private var showHeightPicker = false
    @State private var showingImagePicker = false
    
    // form vars
    @State private var givenName: String = ""
    @State private var familyName: String = ""
    @State private var weight: String = ""
    @State private var birthdate: Date = Date()
    @State private var heightFeet: Int = 0
    @State private var heightInches: Int = 0
    
    @State private var image: Image? = nil
    @State private var originalUIImage: UIImage? = nil
    @State private var updatedUIImage: UIImage? = nil
    
    @State private var userCancellable: AnyCancellable? = nil
    
    @ObservedObject private var locationManager: LocationManager = LocationManager()
    
    func save() {
        let user = User(
            id: nil,
            externalUserId: nil,
            email: nil,
            givenName: givenName,
            familyName: familyName,
            imageExists: nil,
            birthdate: nil,
            weight: nil,
            height: nil,
            isMale: true
        )
        
        var savePromises: [Promise<Void>] = []
        
        if dataHasChanged {
            savePromises.append(userAPI.patchMeUser(user: user).then { user in
                self.userState.userInfo = user
                
                let p = Promise<Void>.pending()
                p.fulfill(())
                return p
            })
        }
        
        if imageHasChanged {
            savePromises.append(userAPI.updateMeUserImage(self.updatedUIImage!))
        }
        
        all(savePromises).then { _ in
            self.routeState.pop()
        }
    }
    
    func loadImage(for userID: Int) {
        self.userAPI.getImage(for: userID).then { uiImage in
            self.image = Image(uiImage: uiImage)
        }
    }
    
    var dataHasChanged: Bool {
        if givenName != userState.userInfo.givenName {
            return true
        }
        
        if familyName != userState.userInfo.familyName {
            return true
        }
        
        return false
    }
    
    var imageHasChanged: Bool {
        if updatedUIImage != nil {
            return true
        }
        
        return false
    }
    
    var disableSaveButton: Bool {
        return !dataHasChanged && !imageHasChanged
    }
    
    var heightStringInFeet: String {
        return "\(heightFeet)\' \(heightInches)\""
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .separator
        UITableView.appearance().backgroundColor = .systemGroupedBackground
        
        return VStack(spacing: 0) {
            VStack {
                HStack(alignment: .center) {
                    Button(action: { self.routeState.pop() }) {
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
                
                Section(header: Text("Measurements (for improved calorie estimation)")) {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.numberPad)
                    }
                    
                    Button(action: {
                        self.showBirthdatePicker = false
                        self.showHeightPicker.toggle()
                    }) {
                        HStack {
                            Text("Height")
                            
                            Spacer()
                            
                            Text(heightStringInFeet)
                                .foregroundColor(Color.secondary)
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        self.showHeightPicker = false
                        self.showBirthdatePicker.toggle()
                    }) {
                        HStack {
                            Text("Birthdate")
                            
                            Spacer()
                            
                            Text(birthdate.monthDayYearString)
                                .foregroundColor(Color.secondary)
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section(header: Text("Location")) {
                    HStack {
                        Text("Location Access")
                        
                        Spacer()
                        
                        Text(locationManager.statusString)
                            .foregroundColor(Color.secondary)
                    }
                    .animation(.none)
                }
            }
            .animation(.default)
            
            if showBirthdatePicker {
                HStack {
                    Spacer()
                    
                    DatePicker(selection: self.$birthdate, in: ...Date(), displayedComponents: .date) {
                        EmptyView()
                    }
                    .fixedSize()
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.bottom)
                .background(Color(UIColor.systemGray4))
                .transition(.move(edge: .bottom))
                .animation(.default)
                .zIndex(2)
            } else if showHeightPicker {
                HStack(spacing: 0) {
                    Spacer()
                    
                    Picker(selection: $heightFeet, label: EmptyView()) {
                        ForEach(0..<10) {
                            Text("\($0) ft")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .clipped()
                    
                    Picker(selection: $heightInches, label: EmptyView()) {
                        ForEach(0..<13) {
                            Text("\($0) in")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .clipped()
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.bottom)
                .background(Color(UIColor.systemGray4))
                .transition(.move(edge: .bottom))
                .animation(.default)
                .zIndex(2)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
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
            self.birthdate = self.userState.userInfo.birthdate ?? Date()
            
            guard let userID = self.userState.userInfo.id else {
                print("Couldn't get userID in order to load image")
                return
            }
            
            self.loadImage(for: userID)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.updatedUIImage = image
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
