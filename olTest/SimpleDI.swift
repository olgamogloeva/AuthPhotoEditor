//
//  SimpleDI.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import Foundation


protocol IDiContainer {
    var photoPermissionManager: PhotoPermissionManager { get }
    
}


class SimpleDIContainer: ObservableObject, IDiContainer {
    
    static let shared = SimpleDIContainer()
    
    let photoPermissionManager = PhotoPermissionManager()
    let authManager = AuthManager()
}
