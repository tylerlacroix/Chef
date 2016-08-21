//
//  ViewController.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit
import AVFoundation

let knownFoodItems = [
    "bell pepper": "tomato",
    //"ping-pong ball": "tomato",
    "Granny Smith": "apple",
    "chambered nautilus, pearly nautilus, nautilus": "onion",
    "dugong, Dugong dugon": "cucumber",
    "Windsor tie": "cucumber",
    "nematode, nematode worm, roundworm": "cucumber"
]

class CameraViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var endButton = UIButton()
    var endLabel = UILabel()
    var rescanLabel = UILabel()
    var background = UILabel()
    var background1 = UILabel()
    var background2 = UILabel()
    //var backButton = UIImageView()
    var findingLabel = UILabel()
    var startLabel = UILabel()
    var xLabel = UILabel()
    var loadBall = UILabel()
    var blurEffectView = UIVisualEffectView()
    var logo = UIImageView()
    var gear = UIImageView()
    var stage = 0
    
    @IBOutlet weak var overlayCamera: UIView!
    
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var labels = [UILabel]()
    var newview = UIView()
    
    lazy var cir: CollectionViewController = {
        var layout = CircularCollectionViewLayout()
        layout.invalidateLayout()
        var collection = CollectionViewController(collectionViewLayout: layout)
        collection.parent = self
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    
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
        
        /*let backImage = UIImage(named: "Back.png")
        backButton = UIImageView(frame: CGRect(x: -35, y: -20, width: 140, height: 100))
        backButton.image = backImage
        backButton.alpha = 0.6
        self.view.addSubview(backButton)*/

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        
        background1 = UILabel(frame: CGRectMake(0, 0, 1000, 1000))
        background1.backgroundColor = UIColor (red:1.0, green:1.0, blue:1.0, alpha:1.0)
        background1.alpha = 1.0
        
        background2 = UILabel(frame: CGRectMake(0, 0, 1000, 1000))
        background2.backgroundColor = UIColor (red:1.00, green:0.93, blue:0.75, alpha:1.0)
        background2.alpha = 0.0
        
        view.addSubview(background1)
        view.addSubview(background2)
        
        let logoImage = UIImage(named: "Logo.png")
        logo = UIImageView(image: logoImage!)
        logo.frame = CGRect(x: 67, y: 231, width: 240, height: 138)
        logo.contentMode = UIViewContentMode.ScaleAspectFit
        logo.tintColor = UIColor (red:1.00, green:0.93, blue:0.75, alpha:1.0)
        logo.alpha = 1.0
        self.view.addSubview(logo)
        
        let gearImage = UIImage(named: "Gear.png")
        gear = UIImageView(image: gearImage!)
        gear.frame = CGRect(x: 317, y: 10, width: 45, height: 45)
        gear.contentMode = UIViewContentMode.ScaleAspectFit
        gear.tintColor = UIColor (red:1.00, green:0.93, blue:0.75, alpha:1.0)
        gear.alpha = 0.0
        self.view.addSubview(gear)
        
        startLabel = UILabel(frame: CGRectMake(50, 500, 250, 60))
        startLabel.backgroundColor = UIColor.clearColor()
        startLabel.textAlignment = NSTextAlignment.Center
        startLabel.text = "tap to start"
        startLabel.font = UIFont(name: "AvenirNext-Regular", size: 40.0)
        startLabel.textColor = UIColor.blackColor()
        startLabel.sizeToFit()
        startLabel.frame.origin.x = (385 - startLabel.frame.size.width)/2
        startLabel.alpha = 0.0
        
        view.addSubview(startLabel)
        
        UIView.animateWithDuration(3.0, delay: 0.0, options: .CurveEaseOut, animations: {
            self.background1.alpha = 0.0
            self.background2.alpha = 0.5
            self.startLabel.alpha = 0.6
            self.logo.alpha = 0.3
            self.gear.alpha = 0.3
            }, completion: {_ in})
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        doneInt()
        
        if (stage == 0) {
            if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                    (imageDataSampleBuffer, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    let image = UIImage(data: imageData)
                    
                    RecognizeImage(UIImagePNGRepresentation(image!)!, callback: { string in
                        if let foodname = string {
                            self.createLabel(foodname)
                        }
                        })
                    //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                }
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
        foodLabel.frame.origin.x = 360-foodLabel.frame.size.width
        foodLabel.alpha = 0.0
        foodLabel.userInteractionEnabled = true
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: "deleteFood:")
        leftSwipe.direction = .Left
        foodLabel.addGestureRecognizer(leftSwipe)
        
        self.labels.append(foodLabel)
        self.labels[self.labels.endIndex - 1].tag = self.labels.endIndex - 1
        
        self.view.addSubview(foodLabel)
        
        UIView.animateWithDuration(2.5, delay: 0.0, options: .CurveEaseOut, animations: {
            var foodLabelFrame = self.labels[self.labels.endIndex - 1].frame
            foodLabelFrame.origin.y -= CGFloat(490 - ((self.labels.endIndex - 1)*65))
            
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
        endLabel.text = "make a meal"
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
        if (stage == 0) {
            
            stage = 1
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
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
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.endLabel.alpha = 0.0
                //self.backButton.alpha = 0.0
                
                }, completion: nil)
            
            UIView.animateWithDuration(0.7, delay: 0.6, options: UIViewAnimationOptions.CurveEaseIn, animations: {
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
                UIView.animateWithDuration(0.8, delay: (Double(i)*0.1), options: .CurveEaseInOut, animations: {
                    var foodLabelFrame = self.labels[i].frame
                    foodLabelFrame.origin.x = 185 - self.labels[i].frame.size.width/2
                    
                    self.labels[i].frame = foodLabelFrame
                    }, completion: {_ in})
            }
            
            rotateView(loadBall)
            
            let delay = 3.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                if (self.stage != 0) {
                    UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        
                        self.findingLabel.alpha = 0.0
                        
                        for i in 0...(self.labels.endIndex - 1) {
                            //self.labels[i].alpha = 0.0
                            self.labels[i].frame.origin.y -= CGFloat(20*(i+1))
                        }
                        
                        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            self.endButton.frame.size.width = 150
                            self.endButton.frame.origin.x -= (150 - 60)/2
                            
                            
                            }, completion: nil)
                        
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        
                            self.loadBall.alpha = 0.0
                            self.xLabel.alpha = 0.0
                            
                            }, completion: nil)
                        
                        UIView.animateWithDuration(0.4, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            
                            self.rescanLabel.alpha = 0.8
                            
                            }, completion: nil)
                        
                        }, completion: nil)
                    
                    self.showRecipes()
                    //self.clear()
                }
            }
            
            rescanLabel = UILabel(frame: CGRectMake(65, 580, 250, 60))
            rescanLabel.backgroundColor = UIColor.clearColor()
            rescanLabel.textAlignment = NSTextAlignment.Center
            rescanLabel.text = "rescan"
            rescanLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
            rescanLabel.textColor = UIColor.whiteColor()
            rescanLabel.alpha = 0.0
            
            self.view.addSubview(rescanLabel)
        }
        else {
            reset()
        }
    }

    func showRecipes() {
        var list = [String]()
        
        for label in labels {
            if let text = label.text {
                list.append(text)
            }
        }
        
        getRecipes(list, callback: { recipes in
            dispatch_async(dispatch_get_main_queue(),{
                self.cir.recipes = recipes
                self.addChildViewController(self.cir)
                self.view.addSubview(self.cir.view)
                self.cir.view.frame.size.height = self.view.frame.height-100
                self.cir.view.alpha = 0.0
                
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.cir.view.alpha = 0.9
                    
                    }, completion: nil)
                //self.presentViewController(cir, animated: true, completion: {})
            })
        })
    }
    
    func rotateView(sender: UILabel) {
        
        sender.layer.anchorPoint = CGPointMake(-2.3, -2.3)
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: { () -> Void in
            sender.transform = CGAffineTransformRotate(sender.transform, CGFloat(-M_PI_2))
        }) { (finished) -> Void in
            self.rotateView(sender)
        }
    }
    
    func deleteFood(sender: UISwipeGestureRecognizer) {
        var senderlaber = sender.view as! UILabel
        UIView.animateWithDuration(0.8, delay: 0.0, options: .CurveEaseInOut, animations: {
            var foodLabelFrame = self.labels[self.labels.indexOf(senderlaber)!].frame
            foodLabelFrame.origin.x = 0 - self.labels[self.labels.indexOf(senderlaber)!].frame.size.width
            
            self.labels[self.labels.indexOf(senderlaber)!].frame = foodLabelFrame
            
            if ((self.labels.indexOf(senderlaber))!+1 <= (self.labels.endIndex - 1)) {
                for i in (self.labels.indexOf(senderlaber))!+1...(self.labels.endIndex - 1) {
                    self.labels[i].frame.origin.y -= 65
                }
            }
            
            }, completion: {_ in})
        
        self.labels.removeAtIndex(self.labels.indexOf(senderlaber)!)
    }
    
    func reset() {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.endButton.alpha = 0.0
            self.endLabel.alpha = 0.0
            self.background.alpha = 0.0
            //self.backButton.alpha = 0.0
            self.findingLabel.alpha = 0.0
            self.xLabel.alpha = 0.0
            self.loadBall.alpha = 0.0
            self.blurEffectView.alpha = 0.0
            self.rescanLabel.alpha = 0.0
            self.stage = 0
            
            self.cir.view.removeFromSuperview()
            self.cir.removeFromParentViewController()
            
            for label in self.labels {
                label.alpha = 0.0
            }
            
            }, completion: { Void in
                self.clear()
        })
        
    }
    
    func clear() {
        self.labels.removeAll()
    }
    func doneInt() {
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.startLabel.alpha = 0.0
            self.logo.alpha = 0.0
            self.background1.alpha = 0.0
            self.background2.alpha = 0.0
            self.gear.alpha = 0.0
            self.blurEffectView.alpha = 0.0
            
            }, completion: {_ in})
    }

    func recipeUses(uses: [String]) {
        for label in labels {
            label.alpha = 0.3
            //label.backgroundColor = UIColor.orangeColor()
        }
        for item in uses {
            for label in labels {
                if label.text == item {
                    label.alpha = 1.0
                    //label.backgroundColor = UIColor.greenColor()()
                }
            }
        }
    }
}

