//
//  ImagePreviewViewController.swift
//  CameraApp
//
//  Created by Nick Shields on 2020-03-25.
//  Copyright © 2020 Nick Shields. All rights reserved.
//

import Foundation
import UIKit


class ImagePreviewViewController : UIViewController {
    
    var capturedImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = capturedImage
    }
    
    
    
    
}
