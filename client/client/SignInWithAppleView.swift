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

struct SignInView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var userAPI: UserAPI
    
    var body: some View {
        return VStack {
            SignInWithAppleView(userState: userState, userAPI: userAPI)
                .frame(width: 200, height: 50)
        }
    }
}

struct SignInDevView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var userAPI: UserAPI

    func signIn() {
        let data = UserRegistrationData(externalUserId: "test.user", email: "test@user.com", givenName: "Calev", familyName: "Muzaffar")
        
        self.userAPI.userRegistrationAndLogin(identityToken: "not.a.token", data: data) { jwt in
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
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        
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
            
            let data = UserRegistrationData(
                externalUserId: credentials.user,
                email: credentials.email ?? "",
                givenName: credentials.fullName?.givenName ?? "",
                familyName: credentials.fullName?.familyName ?? ""
            )
            
            self.parent?.userAPI.userRegistrationAndLogin(identityToken: identityToken, data: data) { jwt in
                defaults.set(jwt.string, forKey: "token")
                                       
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
