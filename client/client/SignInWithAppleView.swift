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
    
    var body: some View {
        return VStack {
            SignInWithAppleView(userState: userState)
                .frame(width: 200, height: 50)
        }
    }
}

// https://developer.apple.com/documentation/signinwithapplerestapi/authenticating_users_with_sign_in_with_apple
struct SignInWithAppleView: UIViewRepresentable {
    var userState: UserState
    
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
            
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": "Bearer \(identityToken)"
            ]
            
            let url = "\(baseURL)/user/register"
            
            struct UserRegistrationResponse: Codable {
                let token: String
            }
            
            AF
                .request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default, headers: headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(let data):
                        let t = try! JSONDecoder().decode(UserRegistrationResponse.self, from: data!)
                        let jwt = try! decode(jwt: t.token)
                        
                        defaults.set(t.token, forKey: "token")
                        
                        self.parent?.userState.jwt = jwt
                        self.parent?.userState.authorization = 1
                    case .failure(let error):
                        print(error)
                    }
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
    }
}
