//
//  MainView.swift
//  olTest
//
//  Created by Olga Mogloeva on 02.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State var image: UIImage?
    @State var tog: Bool = false
    @State var ciFileterShow: Bool = false
    @State var mgRShow: Bool = false
    @State var textShow: Bool = false
    @State var penShow: Bool = false
    @Environment(AuthManager.self) var authManager: AuthManager
    var body: some View {
        VStack {
            HStack {
                if let image {
                    ShareLink(
                        item: image,
                        preview: SharePreview(
                            "Example Image",
                            image: Image(uiImage: image)
                        )
                    ) {
                        Label("Share Image", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                }
                Spacer()
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 5)
                .overlay {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
            HStack {
                Button {
                    tog.toggle()
                } label: {
                    Image(systemName: "photo.badge.plus")
                        .padding()
                }
                
                Button {
                    ciFileterShow.toggle()
                } label: {
                    Image(systemName: "camera.filters")
                        .padding()
                }
                
                Button {
                    penShow.toggle()
                } label: {
                    Image(systemName: "pencil.tip.crop.circle")
                        .padding()
                }
                
                Button {
                    mgRShow.toggle()
                } label: {
                    Image(systemName: "crop.rotate")
                        .padding()
                }
                
                Button {
                    textShow.toggle()
                } label: {
                    Image(systemName: "textformat.alt")
                        .padding()
                }
                
                Button {
                    if let image {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                } label: {
                    Image(systemName: "photo.badge.arrow.down")
                        .padding()
                    }
            }
        }
        
        .fullScreenCover(isPresented: $tog) {
            PhotoPickerView(tog: $tog) { img  in
                image = img
            }
        }
        .fullScreenCover(isPresented: $ciFileterShow) {
            
                if let selectedIMage = Binding($image) {
                    ImageEditorView(image: selectedIMage, isVisible: $ciFileterShow)
                    
            }
        }
        .fullScreenCover(isPresented: $mgRShow) {
            
                if let selectedIMage = Binding($image) {
                    
                    ScaleAndRotationView(image: selectedIMage, isVisible: $mgRShow)
            }
        }
        .fullScreenCover(isPresented: $textShow) {
            
                if let selectedIMage = Binding($image) {
                    
                    TextEffect(image: selectedIMage, isVisible: $textShow)
            }
        }
        .fullScreenCover(isPresented: $penShow) {
            
                if let selectedIMage = Binding($image) {
                    
                    DrawingView(image: selectedIMage, isVisible: $penShow)
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
