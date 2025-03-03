//
//  AuthManager.swift
//  olTest
//
//  Created by Olga on 03.03.2025.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

@Observable
class AuthManager {
     var errorMessage: String?
     var isUserSignedIn: Bool = false
     var isEmailVerified: Bool = false
     var emailVerificationSent: Bool = false
     var passwordResetSent: Bool = false

    
    func checkUseredLogedIn()  {
        isUserSignedIn = Auth.auth().currentUser != nil
    }
    
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "No Firebase clientID found"
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            self.errorMessage = "No root view controller found"
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected error occurred, please retry"
                }
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, authError in
                DispatchQueue.main.async {
                    if let authError = authError {
                        self.errorMessage = authError.localizedDescription
                    } else {
                        self.isUserSignedIn = true
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isUserSignedIn = true
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.passwordResetSent = true
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    self.sendEmailVerification(user: user)
                }
            }
        }
    }
    
    func signOut() {
        do {
          try Auth.auth().signOut()
        isUserSignedIn = false
        } catch {
          print("Sign out error")
        }
    }

    func sendEmailVerification(user: FirebaseAuth.User) {
        Task {
            do {
                try await user.sendEmailVerification()
                DispatchQueue.main.async {
                    self.emailVerificationSent = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                }
            }
        }
    }

    func checkEmailVerification() {
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.errorMessage = "No user is currently signed in."
            }
            return
        }

        Task {
            do {
                try await user.reload()
                DispatchQueue.main.async {
                    self.isEmailVerified = user.isEmailVerified
                    if user.isEmailVerified {
                        self.isUserSignedIn = true
                    } else {
                        self.errorMessage = "Email not verified yet. Please check your inbox."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to check email verification: \(error.localizedDescription)"
                }
            }
        }
    }
}
