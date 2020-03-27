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
    
    var session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            self.initializeCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.initializeCaptureSession()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            print("Something went wrong.")
        }
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
        
        // MARK: Setting up inputs
        
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .back)
        
        //Add Camera
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            session.canAddInput(videoDeviceInput)
            else {return}
        session.addInput(videoDeviceInput)
        
        //Add Microphone
        guard
            let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!),
            session.canAddInput(audioDeviceInput)
            else {return}
        session.addInput(audioDeviceInput)
        
        
       // MARK: Setting up outputs
        
        let videoOutput = AVCaptureVideoDataOutput()
        let audioOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(audioOutput) else {return}
        guard session.canAddOutput(videoOutput) else {return}
        
        session.sessionPreset = .high
        session.addOutput(videoOutput)
        session.addOutput(audioOutput)
        
        session.commitConfiguration()
    
        
        //session.sessionPreset = AVCaptureSession.Preset.high
        //camera = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back)
        
        /*do{
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            
        }catch{
            print(error.localizedDescription)
        }*/
        
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
