//
//  Untitled.swift
//  olTest
//
//  Created by Olga on 03.03.2025.
//

import SwiftUI
import UniformTypeIdentifiers

extension UIImage: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .png) { image in
            image.pngData() ?? Data()
        } importing: { data in
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "Invalid Image Data", code: -1, userInfo: nil)
            }
            return image
        }
    }
}
