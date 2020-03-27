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
        
        self.authorizeVideo()
        self.authorizeAudio()
        self.initializeCaptureSession()
        

        // Do any additional setup after loading the view.
    }
    
    func authorizeVideo(){
        let semaphore = DispatchSemaphore(value:0)
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            semaphore.signal()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Access Granted")
                }
            }
            semaphore.signal()
        case .denied:
            semaphore.signal()
        case .restricted:
            semaphore.signal()
        @unknown default:
            print("Something went wrong.")
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    func authorizeAudio(){
        let semaphore = DispatchSemaphore(value:0)
        switch AVCaptureDevice.authorizationStatus(for: .audio){
        case .authorized:
            print("Already Authorized!")
            semaphore.signal()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.initializeCaptureSession()
                }
            }
            semaphore.signal()
        case .denied:
            semaphore.signal()
        case .restricted:
            semaphore.signal()
        @unknown default:
            print("Something went wrong.")
            semaphore.signal()
        }
        
        semaphore.wait()
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
        let audioDevice = AVCaptureDevice.default(for: .audio)
        
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
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        let audioOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(audioOutput) else {return}
        guard session.canAddOutput(videoOutput) else {return}
        
        session.sessionPreset = .high
        session.addOutput(videoOutput)
        session.addOutput(audioOutput)
        
        session.commitConfiguration()
        
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

extension ViewController : AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        print("Hello I am here!")
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
