//
//  RootView.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import SwiftUI


@Observable
class RootViewModel {
    let permissionManager = SimpleDIContainer.shared.photoPermissionManager
    let authManager = SimpleDIContainer.shared.authManager
    
}


struct RootView: View {
    @State private var vm = RootViewModel()
    
    
    var body: some View {
        VStack {
            if !vm.authManager.isUserSignedIn {
                SignInView()
            } else {
                if vm.permissionManager.isAuthorized {
                    ContentView()
                    
                } else {
                    PhotoPermissionView(permissionManager:  vm.permissionManager)
                }
            }
        }.environment(vm.authManager)
        .onAppear {
            vm.authManager.checkUseredLogedIn()
        }
    }
}
