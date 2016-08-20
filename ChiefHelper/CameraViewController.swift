//
//  ViewController.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    
    @IBOutlet weak var overlayCamera: UIView!
    
    
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var labels = [UILabel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Next(sender: AnyObject) {
        
        getRecipes(["chicken breast", "bell pepper"], callback: { recipes in
            var layout = CircularCollectionViewLayout()
            layout.invalidateLayout()
            var cir = CollectionViewController(collectionViewLayout: layout)
            cir.recipes = recipes
            self.presentViewController(cir, animated: true, completion: {})
        })
    }
    
    
    
    func beginSession() {
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            // use input
        } catch {
            fatalError("Could not create capture device input.")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        let bounds:CGRect = view.layer.bounds;
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer!.bounds = bounds;
        previewLayer!.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        
        let newview = UIView(frame: self.view.frame)
        self.view.insertSubview(newview, atIndex: 0)
        
        newview.layer.addSublayer(previewLayer!)
        previewLayer?.frame = overlayCamera.bounds
        captureSession.startRunning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                var foodLabel = UILabel(frame: CGRectMake(250, 500, 100, 40))
                foodLabel.textAlignment = NSTextAlignment.Right
                foodLabel.backgroundColor = UIColor.orangeColor()
                foodLabel.text = "Orange"
                foodLabel.font = UIFont(name: "Montserrat-Light", size: 16.0)
                foodLabel.textColor = UIColor.whiteColor()
                foodLabel.sizeToFit()
                foodLabel.layer.borderColor = UIColor.orangeColor().CGColor
                foodLabel.layer.borderWidth = 3.0;
                foodLabel.layer.cornerRadius = 2
                foodLabel.layer.masksToBounds = true
                
                
                self.labels.append(foodLabel)
                
                self.view.addSubview(foodLabel)
                
                UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                    var foodLabelFrame = self.labels[self.labels.endIndex - 1].frame
                    foodLabelFrame.origin.y -= CGFloat(350 - ((self.labels.endIndex - 1)*50))
                    
                    self.labels[self.labels.endIndex - 1].frame = foodLabelFrame
                    }, completion: {_ in})
            }
        }
    }

}

