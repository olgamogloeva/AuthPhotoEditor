//
//  SignInView.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import SwiftUI
import FirebaseAuth


struct SignInView: View {
    @Environment(AuthManager.self) var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailErrorMessage: String?
    @State private var isNavigatingToSignUp = false
    @State private var showingPasswordResetAlert = false
    
    var isSignInDisabled: Bool {
        email.isEmpty || password.isEmpty || emailErrorMessage != nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) { newValue in
                    emailErrorMessage = ValidationManager.isValidEmail(newValue) ? nil : "Invalid email format"
                }
            
            if let emailError = emailErrorMessage {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                if emailErrorMessage == nil {
                    authManager.signIn(email: email, password: password)
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSignInDisabled ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isSignInDisabled)
            
            Button(action: {
                if !email.isEmpty {
                    authManager.resetPassword(email: email)
                    showingPasswordResetAlert = true
                } else {
                    emailErrorMessage = "Enter your email to reset password"
                }
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text("Don't have an account?")
                NavigationLink(destination: SignUpView().environment(authManager)) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            Spacer()
            
            Button(action: {
                authManager.signInWithGoogle()
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .alert("Password Reset", isPresented: $showingPasswordResetAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your email for password reset instructions.")
        }
    }
}
