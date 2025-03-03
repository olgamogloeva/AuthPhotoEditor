//
//  Permission.swift
//  olTest
//
//  Created by Olga Mogloeva on 01.03.2025.
//

import SwiftUI
import Photos
import Combine

@Observable
class PhotoPermissionManager {
    var isAuthorized: Bool = false

    init() {
        checkPermission()
    }

    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        DispatchQueue.main.async {
            self.isAuthorized = (status == .authorized || status == .limited)
        }
    }

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = (status == .authorized || status == .limited)
            }
        }
    }
}


struct PhotoPermissionView: View {
    @State var permissionManager: PhotoPermissionManager

    var body: some View {
        VStack {
            Text("This app requires access to your photo library.")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                permissionManager.requestPhotoLibraryAccess()
            }) {
                Text("Request Access")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
