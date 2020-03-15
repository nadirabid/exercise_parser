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

extension String: Error { }

enum CredentialsOrError {
  case credentials(user: String, givenName: String?, familyName: String?, email: String?)
  case error(_ error: Error)
}

struct Credentials {
  let user: String
  let givenName: String?
  let familyName: String?
  let email: String?
}

// https://medium.com/better-programming/swiftui-sign-in-with-apple-c1e70ccb2a71
// https://github.com/Q42/iOS-Demo-SignInWithApple-SwiftUI

struct SignInView: View {
    @State var name: String = ""
    
    var body: some View {
        return VStack {
            SignInWithAppleView(name: $name)
                .frame(width: 200, height: 50)
        }
    }
}

// https://developer.apple.com/documentation/signinwithapplerestapi/authenticating_users_with_sign_in_with_apple
struct SignInWithAppleView: UIViewRepresentable {
    @Binding var name: String
    var dataPublisher: AnyCancellable? = nil
    
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
                print("credentials not found....")
                return
            }
            
            print("scopes", credentials.authorizedScopes)
            
            let identityToken = String(data: credentials.identityToken!, encoding: .utf8)!
                        
            let defaults = UserDefaults.standard
            defaults.set(credentials.user, forKey: "userId")
            parent?.name = "\(credentials.fullName?.givenName ?? "")"
            
            let data = UserRegistrationData(
                userId: credentials.user,
                email: credentials.email ?? "",
                givenName: credentials.fullName?.givenName ?? "",
                familyName: credentials.fullName?.familyName ?? ""
            )
            
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": "Bearer \(identityToken)"
            ]
            
            let url = "\(baseURL)/user/register"
            
            AF.request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default, headers: headers)
                .validate()
                .response(queue: DispatchQueue.main) { (data) in
                    print(data)
                }
        }
        
        struct UserRegistrationData: Codable {
            let userId: String
            let email: String?
            let givenName: String?
            let familyName: String?
            
            private enum CodingKeys: String, CodingKey {
                case userId = "external_user_id"
                case email = "email"
                case givenName = "given_name"
                case familyName = "family_name"
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
