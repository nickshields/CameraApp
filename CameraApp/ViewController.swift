//
//  ViewController.swift
//  CameraApp
//
//  Created by Nick Shields on 2020-03-25.
//  Copyright © 2020 Nick Shields. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
        // Do any additional setup after loading the view.
    }
    
    func displayCapturedPhoto(capturedPhoto : UIImage){
        let imagePreviewViewController = storyboard?.instantiateViewController(identifier: "ImagePreviewViewController") as! ImagePreviewViewController
    
        imagePreviewViewController.capturedImage = capturedPhoto
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        takePicture()
    }
    

    func initializeCaptureSession(){
        session.sessionPreset = AVCaptureSession.Preset.high
        camera = AVCaptureDevice.default(for: .video)
        
        do{
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            
        }catch{
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        session.startRunning()
    }
    
    func takePicture(){
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
        
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        }else{
            if let imageData = photo.fileDataRepresentation() {
                if let finalImage = UIImage(data: imageData){
                    displayCapturedPhoto(capturedPhoto: finalImage)
            }
        }
    }
    
}

}
