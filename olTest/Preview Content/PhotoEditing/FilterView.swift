//
//  FilterView.swift
//  olTest
//
//  Created by Olga Mogloeva on 01.03.2025.
//
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageEditorView: View {
    let context = CIContext()
    
    @Binding  var image: UIImage
    @Binding var isVisible: Bool
    @State private var filteredImage: UIImage?
    @State private var filterIntensity: Float = 0.5
    @State private var selectedFilter: CIFilter = CIFilter.sepiaTone()
    
    let filters: [(String, CIFilter)] = [
        ("Sepia", CIFilter.sepiaTone()),
        ("Noir", CIFilter.photoEffectNoir()),
        ("Mono", CIFilter.photoEffectMono()),
        ("Chrome", CIFilter.photoEffectChrome()),
        ("Blur", CIFilter.gaussianBlur()),
        ("Invert", CIFilter.colorInvert()),
        ("Vignette", CIFilter.vignette()),
        ("Pixelate", CIFilter.pixellate())
    ]
    
    var body: some View {
        VStack {
            if let filteredImage = filteredImage {
                Image(uiImage: filteredImage)
                    .resizable()
                    .scaledToFit()
            } else  {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filters, id: \.0) { filter in
                        Button(action: {
                            selectedFilter = filter.1
                            applyFilter()
                        }) {
                            Text(filter.0)
                                .padding()
                                .background(selectedFilter == filter.1 ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            
            if selectedFilter.inputKeys.contains(kCIInputIntensityKey) {
                Slider(value: $filterIntensity, in: 0...1) {
                    Text("Intensity")
                }
                .padding()
                .onChange(of: filterIntensity) { _ in
                    applyFilter()
                }
            }

            Button("Apply Filter") {
                applyFilter()
                if let filteredImage {
                    image = filteredImage
                }
               
                isVisible = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func applyFilter() {
        guard let ciImage = CIImage(image: image) else { return }
        
        selectedFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if selectedFilter.inputKeys.contains(kCIInputIntensityKey) {
            selectedFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }

        if let outputImage = selectedFilter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            filteredImage = UIImage(cgImage: cgImage)
        }
    }
}
