//
//  SignInWithApple.swift
//  client
//
//  Created by Nadir Muzaffar on 3/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import Combine
import Alamofire
import JWTDecode

// https://medium.com/better-programming/swiftui-sign-in-with-apple-c1e70ccb2a71
// https://github.com/Q42/iOS-Demo-SignInWithApple-SwiftUI

// https://www.myfonts.com/fonts/yellow-design/eveleth/
// https://www.myfonts.com/fonts/typemates/cera-stencil/

struct SignInView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var userAPI: UserAPI
    
    var body: some View {
        GeometryReader { geometry in
            return VStack {
                VStack {
                    Spacer()
                    
                    Text("FOR THE ATHLETES")
                        .foregroundColor(Color(0xF43605))
                        .font(.caption)
                        .fontWeight(.heavy)
                    
                    Text("RYDEN")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .tracking(10)
                        .foregroundColor(Color.white)
                    
                    HStack(alignment: .center) {
                        Text("FORM")
                            .foregroundColor(Color(0xF43605))
                            .font(.callout)
                            .fontWeight(.heavy)
                        
                        Text("&")
                            .foregroundColor(Color(0xF43605))
                            .font(.subheadline)
                            .fontWeight(.heavy)
                        
                        Text("WILL")
                            .foregroundColor(Color(0xF43605))
                            .font(.callout)
                            .fontWeight(.heavy)
                    }
                    
                    Spacer()
                    
                    SignInWithAppleView(userState: self.userState, userAPI: self.userAPI)
                        .frame(width: 200, height: 40)
                        .padding(.bottom)
                }
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
                .frame(width: geometry.size.width)
                .background(appColor)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SignInDevView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var userAPI: UserAPI

    func signIn() {
        let data = User(
            id: nil,
            externalUserId: "fake.user.id",
            email: "fake@user.com",
            givenName: "Fake",
            familyName: "User"
        )
        
        self.userAPI.userRegistrationAndLogin(identityToken: "not.a.token", data: data) { (jwt, user) in
            self.userState.userInfo = user
            self.userState.jwt = jwt
            self.userState.authorization = 1
        }
    }
    
    var body: some View {
        return VStack {
            Button(action: { self.signIn() }) {
                Text("Sign in")
            }
        }
    }
}

// https://developer.apple.com/documentation/signinwithapplerestapi/authenticating_users_with_sign_in_with_apple
struct SignInWithAppleView: UIViewRepresentable {
    var userState: UserState
    var userAPI: UserAPI
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        
        button.addTarget(
            context.coordinator,
            action:  #selector(Coordinator.didTapButton),
            for: .touchUpInside
        )
        
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleView?
        
        init(_ parent: SignInWithAppleView) {
            self.parent = parent
            super.init()
        }
        
        @objc func didTapButton() {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.presentationContextProvider = self
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            let vc = UIApplication.shared.windows.last?.rootViewController
            return (vc?.view.window!)!
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
                debugPrint("credentials not found....")
                return
            }
            
            let identityToken = String(data: credentials.identityToken!, encoding: .utf8)!
                        
            let defaults = UserDefaults.standard
            defaults.set(credentials.user, forKey: "userId")
            
            let data = User(
                id: nil,
                externalUserId: credentials.user,
                email: credentials.email ?? "",
                givenName: credentials.fullName?.givenName ?? "",
                familyName: credentials.fullName?.familyName ?? ""
            )
            
            self.parent?.userAPI.userRegistrationAndLogin(identityToken: identityToken, data: data) { (jwt, user) in
                let userJSON = try! JSONEncoder().encode(user)
                
                defaults.set(jwt.string, forKey: "token")
                defaults.set(String(data: userJSON, encoding: .utf8), forKey: "userInfo")
                                       
                self.parent?.userState.userInfo = user
                self.parent?.userState.jwt = jwt
                self.parent?.userState.authorization = 1
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // TODO: handle error
        }
    }
}


struct SignInWithApple_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(UserState())
            .environmentObject(UserAPI())
    }
}
