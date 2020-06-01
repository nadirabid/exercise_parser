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
    @EnvironmentObject var userAPI: AuthAPI
    
    var body: some View {
        return ZStack{
            appColor .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                Text("FOR THE ATHLETES")
                    .foregroundColor(secondaryAppColor)
                    .font(.caption)
                    .fontWeight(.heavy)
                    .fixedSize()
                
                Text("RYDEN")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .tracking(10)
                    .foregroundColor(Color.white)
                    .fixedSize()
                
                HStack(alignment: .center) {
                    Text("FORM")
                        .foregroundColor(secondaryAppColor)
                        .font(.callout)
                        .fontWeight(.heavy)
                        .fixedSize()
                    
                    Text("&")
                        .foregroundColor(secondaryAppColor)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    
                    Text("WILL")
                        .foregroundColor(secondaryAppColor)
                        .font(.callout)
                        .fontWeight(.heavy)
                        .fixedSize()
                }
                
                Spacer()
                
                SignInWithAppleView(userState: self.userState, userAPI: self.userAPI)
                    .frame(width: 200, height: 40)
                    .padding(.bottom)
            }
        }
    }
}

struct SignInDevView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var userAPI: AuthAPI
    
    func signIn() {
        let data = User(
            id: nil,
            externalUserId: "fake.user.id",
            email: "fake@user.com",
            givenName: "Fake",
            familyName: "User",
            imageExists: nil,
            birthdate: nil,
            weight: nil,
            height: nil,
            isMale: true
        )
        
        self.userAPI.userRegistrationAndLogin(identityToken: "not.a.token", data: data) { (jwt, user) in
            self.userState.userInfo = user
            self.userState.jwt = jwt
            self.userState.authorization = 1
        }
    }
    
    var body: some View {
        return ZStack{
            appColor .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                Text("FOR THE ATHLETES")
                    .foregroundColor(secondaryAppColor)
                    .font(.caption)
                    .fontWeight(.heavy)
                
                Text("RYDEN")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .tracking(10)
                    .foregroundColor(Color.white)
                
                HStack(alignment: .center) {
                    Text("FORM")
                        .foregroundColor(secondaryAppColor)
                        .font(.callout)
                        .fontWeight(.heavy)
                    
                    Text("&")
                        .foregroundColor(secondaryAppColor)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    
                    Text("WILL")
                        .foregroundColor(secondaryAppColor)
                        .font(.callout)
                        .fontWeight(.heavy)
                }
                
                Spacer()
                
                Button(action: { self.signIn() }) {
                    Text("Sign in")
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            self.signIn()
        }
    }
}

// https://developer.apple.com/documentation/signinwithapplerestapi/authenticating_users_with_sign_in_with_apple
struct SignInWithAppleView: UIViewRepresentable {
    var userState: UserState
    var userAPI: AuthAPI
    
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
                familyName: credentials.fullName?.familyName ?? "",
                imageExists: nil,
                birthdate: nil,
                weight: nil,
                height: nil,
                isMale: true
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
            .environmentObject(AuthAPI())
    }
}
