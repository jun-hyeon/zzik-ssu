//
//  ImagePickerManager.swift
//  Runner
//
//  Created by 최준현 on 1/12/26.
//
import UIKit
import PhotosUI
import Photos
import Flutter
class ImagePickerManager: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var flutterResult: FlutterResult?
    private weak var viewController: UIViewController?
    
    func pickImage(viewController: UIViewController, result: @escaping FlutterResult){
        self.viewController = viewController
        self.flutterResult = result
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        viewController.present(picker, animated: true, completion: nil)
    }

    func pickImageFromCamera(viewController: UIViewController, result: @escaping FlutterResult){
        self.viewController = viewController
        self.flutterResult = result
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            viewController.present(picker, animated: true, completion: nil)
        }else{
            result(FlutterError(code: "UNAVAILABLE", message: "Camera not available", details: nil))
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            flutterResult?(nil)
            flutterResult = nil
            return
        }
        
        itemProvider.loadObject(ofClass: UIImage.self) {[weak self](image, error) in
            guard let self = self else {return}
            
            if let error = error{
                self.flutterResult?(FlutterError(code: "LOAD_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let uiImage = image as? UIImage, let data = uiImage.jpegData(compressionQuality: 0.8) else{
                self.flutterResult?(FlutterError(code: "CONVERT_ERROR", message: "Failed to convert image", details: nil))
                return
            }
            
            if let path = self.saveImageToTemp(data: data){
                self.flutterResult?(path)
            }else{
                self.flutterResult?(FlutterError(code: "SAVE_ERROR", message: "Failed to save image", details: nil))
            }
            self.flutterResult = nil
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 0.8) else{
            self.flutterResult?(FlutterError(code: "CONVERT_ERROR", message: "Failed to convert image", details: nil))
             self.flutterResult = nil
            return
        }
        if let path = self.saveImageToTemp(data: data){
            self.flutterResult?(path)
        }else{
            self.flutterResult?(FlutterError(code: "SAVE_ERROR", message: "Failed to save image", details: nil))
        }
        self.flutterResult = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.flutterResult?(nil)
        self.flutterResult = nil
    }
    private func saveImageToTemp(data: Data) -> String?{
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}
