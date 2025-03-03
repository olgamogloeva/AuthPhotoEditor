//
//  AuthView.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import SwiftUI
import Foundation
import FirebaseAuth


struct User {
    let uid: String
    let email: String
}

class LoginViewModel: ObservableObject{
    
    @Published var email = "john@company.com"
    @Published var password = "1234567"
    @Published private var _currentUser : User? = nil
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    
    private var handler = Auth.auth().addStateDidChangeListener{_,_ in }
    
    var currentUser: User {
        return _currentUser ?? User(uid: "", email: "")
    }
    
    init(){
        handler = Auth.auth().addStateDidChangeListener{ auth,user in
            if let user = user {
                self._currentUser = User(uid: user.uid, email: user.email!)
                self.isLoggedIn = true
            } else {
                self._currentUser = nil
                self.isLoggedIn = false
            }
        }
    }
    
    func signIn() async {
        hasError = false
        do{
            try await Auth.auth().signIn(withEmail: email, password: password)
        }catch{
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        hasError = false
        do{
            try Auth.auth().signOut()
            
        }catch{
            hasError = true
            errorMessage = error.localizedDescription
        }
        
    }
    
    deinit{
        Auth.auth().removeStateDidChangeListener(handler)
    }
}

struct LoginView: View {
    
    @ObservedObject var vm = LoginViewModel()
    
    fileprivate func EmailInput() -> some View {
        TextField("Email", text: $vm.email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        SecureField("Password", text: $vm.password)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func LoginButton() -> some View {
        Button(action: {
            Task {
                await vm.signIn()
            }
        }) {
            Text("Sign In")
        }
    }
    fileprivate func LogoutButton() -> some View {
        Button(action: {
            Task {
                await vm.signOut()
            }
        }) {
            Text("Log Out")
        }
    }
    
    fileprivate func UserInfo() -> some View {
        VStack{
            Text("UID: \(vm.currentUser.uid)")
            Text("Email: \(vm.currentUser.email)")
            LogoutButton()
        }
        
    }
    
    var body: some View {
        VStack {
            if(vm.isLoggedIn){
                UserInfo()
            }else{
                EmailInput()
                PasswordInput()
                LoginButton()
            }
        }
        .alert("Error", isPresented: $vm.hasError) {
        } message: {
            Text(vm.errorMessage)
        }
        .padding()
    }
}
