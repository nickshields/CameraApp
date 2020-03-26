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

}

