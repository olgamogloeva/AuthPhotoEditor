//
//  SignUpView.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import SwiftUI
import Foundation

struct SignUpView: View {
    @Environment(AuthManager.self) var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var emailErrorMessage: String?
    @State private var passwordErrorMessage: String?

    var isSignUpDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty || emailErrorMessage != nil || passwordErrorMessage != nil
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disabled(authManager.emailVerificationSent)
                .onChange(of: email) { newValue in
                    emailErrorMessage = ValidationManager.isValidEmail(newValue) ? nil : "Invalid email format"
                }

            if let emailError = emailErrorMessage {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(authManager.emailVerificationSent)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(authManager.emailVerificationSent)
                .onChange(of: confirmPassword) { newValue in
                    passwordErrorMessage = ValidationManager.doPasswordsMatch(password, newValue) ? nil : "Passwords do not match"
                }

            if let passwordError = passwordErrorMessage {
                Text(passwordError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            if !authManager.emailVerificationSent {
                Button(action: {
                    if !isSignUpDisabled {
                        authManager.signUp(email: email, password: password)
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSignUpDisabled ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isSignUpDisabled)
            } else {
                Text("A verification email has been sent to \(email). Please check your inbox and verify your email before continuing.")
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button(action: {
                authManager.checkEmailVerification()
            }) {
                Text("Check Email Verification")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .opacity(authManager.emailVerificationSent ? 1 : 0)

            Spacer()
        }
        .padding()
    }
}
