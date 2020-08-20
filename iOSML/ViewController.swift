//
//  ViewController.swift
//  iOSML
//
//  Created by Andrew on 05.08.2020.
//  Copyright © 2020 itis.tim. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var mlImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func pickImageButton(_ sender: UIButton) {
        getimage()
    }
    @IBAction func classifyButton(_ sender: UIButton) {
        excecuteRequest(image: mlImageView.image!)
    }
    
    func excecuteRequest(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.mlrequest()])
            } catch {
                print("Failed to get the description")
            }
        }
    }
    
    func mlrequest() -> VNCoreMLRequest {
        var myrequest: VNCoreMLRequest?
        let modelobj = ImageClassifier()
        do {
            let petmodel = try VNCoreMLModel(for: modelobj.model)
            
            myrequest = VNCoreMLRequest(model: petmodel, completionHandler: { (request, error) in
                if let classificationresult = request.results as? [VNClassificationObservation] {
                    DispatchQueue.main.async {
                        self.resultLabel.text = classificationresult.first!.identifier
                    }
                }
                else {
                    print("Unable to get the results")
                }
            })
        } catch {
            print("Unable to create a request")
        }
        myrequest!.imageCropAndScaleOption = .centerCrop
        return myrequest!
    }
}


extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func getimage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let fimage = info[.editedImage] as!UIImage
        mlImageView.image = fimage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
