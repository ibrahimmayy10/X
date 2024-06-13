//
//  VideoPicker.swift
//  X
//
//  Created by İbrahim Ay on 10.06.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import AVKit

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoUrl: URL?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let url = url, error == nil {
                        let tempDirectory = FileManager.default.temporaryDirectory
                        let localURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
                        do {
                            try FileManager.default.copyItem(at: url, to: localURL)
                            DispatchQueue.main.async {
                                self.parent.selectedVideoUrl = localURL
                            }
                        } catch {
                            print("Error copying video file: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
