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
    var endButton = UIButton()
    var endLabel = UILabel()
    var background = UILabel()
    var backButton = UIImageView()
    var findingLabel = UILabel()
    var xLabel = UILabel()
    var loadBall = UILabel()
    
    @IBOutlet weak var overlayCamera: UIView!
    
    
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var labels = [UILabel]()
    var newview = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
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
        
        let backImage = UIImage(named: "Back.png")
        backButton = UIImageView(frame: CGRect(x: -35, y: -20, width: 140, height: 100))
        backButton.image = backImage
        backButton.alpha = 0.6
        self.view.addSubview(backButton)

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        
        newview = UIView(frame: self.view.frame)
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
                let image = UIImage(data: imageData)
                
                RecognizeImage(UIImagePNGRepresentation(image!)!, callback: { string in
                    self.createLabel(string)
                    })
                //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                
                
                
            }
        }
    }
    
    func createLabel(labelName: String) {
        
        let foodLabel = UILabel(frame: CGRectMake(280, 550, 100, 40))
        foodLabel.textAlignment = NSTextAlignment.Center
        foodLabel.backgroundColor = UIColor.orangeColor()
        foodLabel.text = labelName
        foodLabel.font = UIFont(name: "AvenirNext-Regular", size: 20.0)
        foodLabel.textColor = UIColor.whiteColor()
        foodLabel.sizeToFit()
        foodLabel.layer.borderColor = UIColor.orangeColor().CGColor
        foodLabel.frame.size.height += 5
        foodLabel.frame.size.width += 10
        foodLabel.layer.borderWidth = 3.0;
        foodLabel.layer.cornerRadius = 4
        foodLabel.layer.masksToBounds = true
        foodLabel.alpha = 0.0
        
        self.labels.append(foodLabel)
        
        self.view.addSubview(foodLabel)
        
        UIView.animateWithDuration(2.5, delay: 0.0, options: .CurveEaseOut, animations: {
            var foodLabelFrame = self.labels[self.labels.endIndex - 1].frame
            foodLabelFrame.origin.y -= CGFloat(540 - ((self.labels.endIndex - 1)*50))
            
            self.labels[self.labels.endIndex - 1].frame = foodLabelFrame
            }, completion: {_ in})
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.labels[self.labels.endIndex - 1].alpha = 0.8
            }, completion: nil)
        
        if (self.labels.endIndex == 1) {endFunc()}
        
    }
    
    func endFunc() {
        endButton = UIButton(frame: CGRectMake(65, 580, 250, 60))
        endButton.backgroundColor = UIColor.redColor()
        endButton.layer.borderColor = UIColor.redColor().CGColor
        endButton.layer.borderWidth = 3.0;
        endButton.layer.masksToBounds = true
        endButton.layer.cornerRadius = 30
        endButton.alpha = 0.0
        endButton.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(endButton)
        
        endLabel = UILabel(frame: CGRectMake(65, 580, 250, 60))
        endLabel.backgroundColor = UIColor.clearColor()
        endLabel.textAlignment = NSTextAlignment.Center
        endLabel.text = "Make a meal"
        endLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
        endLabel.textColor = UIColor.whiteColor()
        endLabel.alpha = 0.0
        
        self.view.addSubview(endLabel)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.endLabel.alpha = 0.6
            self.endButton.alpha = 0.6
            }, completion: nil)
    }
    
    func backButtonTapped() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        
        self.view.insertSubview(blurEffectView, atIndex: 1)
        
        background = UILabel(frame: CGRectMake(0, 0, 1000, 1000))
        background.backgroundColor = UIColor (red:1.00, green:0.93, blue:0.75, alpha:1.0)
        background.alpha = 0.0
        
        self.view.insertSubview(background, atIndex: 2)
        
        findingLabel = UILabel(frame: CGRectMake(50, 520, 250, 60))
        findingLabel.backgroundColor = UIColor.clearColor()
        findingLabel.textAlignment = NSTextAlignment.Center
        findingLabel.text = "Finding available recipes"
        findingLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
        findingLabel.textColor = UIColor.blackColor()
        findingLabel.sizeToFit()
        findingLabel.alpha = 0.0
        
        self.view.addSubview(findingLabel)
        
        xLabel = UILabel(frame: CGRectMake(174, 574, 250, 60))
        xLabel.text = "x"
        xLabel.font = UIFont(name: "ArialRoundedMTBold", size: 60.0)
        xLabel.textColor = UIColor (red:1.00, green:0.93, blue:0.75, alpha:1.0)
        xLabel.alpha = 0.0
        
        self.view.addSubview(xLabel)
        
        loadBall = UILabel(frame: CGRectMake(185, 605, 10, 10))
        loadBall.backgroundColor = UIColor.redColor()
        loadBall.layer.borderColor = UIColor.redColor().CGColor
        loadBall.layer.borderWidth = 3.0;
        loadBall.layer.masksToBounds = true
        loadBall.layer.cornerRadius = 5
        loadBall.alpha = 0.0
        
        self.view.addSubview(loadBall)
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.endLabel.alpha = 0.0
            self.backButton.alpha = 0.0
            
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.7, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.xLabel.alpha = 1.0
            
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.background.alpha = 0.5
            self.endButton.frame.size.width = 60
            self.endButton.frame.origin.x += (250 - 60)/2
            
            self.findingLabel.alpha = 0.8
            self.loadBall.alpha = 0.6
            
            }, completion: nil)
        
        for i in 0...(self.labels.endIndex - 1) {
            UIView.animateWithDuration(1.0, delay: (Double(i)*0.2), options: .CurveEaseOut, animations: {
                var foodLabelFrame = self.labels[i].frame
                foodLabelFrame.origin.x -= 125
                
                self.labels[i].frame = foodLabelFrame
                }, completion: {_ in})
        }
        
        rotateView(loadBall)
    }
    
    func rotateView(sender: UILabel) {
        
        sender.layer.anchorPoint = CGPointMake(-2.3, -2.3)
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: { () -> Void in
            sender.transform = CGAffineTransformRotate(sender.transform, CGFloat(-M_PI_2))
        }) { (finished) -> Void in
            self.rotateView(sender)
        }
    }
}

