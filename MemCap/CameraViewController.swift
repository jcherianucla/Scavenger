//
//  CameraViewController.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/21/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController,
    UIImagePickerControllerDelegate
{
    var ref = FIRDatabase.database().reference()

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var imageTaken: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    
    var didTakeImage = false
    var shouldTransferData = false
    var imageCaptured: UIImage?
    
    @IBAction func sendImage(sender: AnyObject)
    {
        //Used to Unwind segue
    }
    
    //Cancel the current photo taken, to take another photo
    @IBAction func cancelImage(sender: AnyObject)
    {
        self.imageTaken.hidden = true
        self.didTakeImage = false
        self.cancelButton.hidden = true
        self.sendButton.hidden = true
    }
    //Go back to Map controller without saving any image
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendButton.hidden = true
        self.cancelButton.hidden = true
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Once the View has surfaced, we create the preview layer
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
        
    }
    
    //If we should transfer data, then we pass the image back to Map View Controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (shouldTransferData == true)
        {
            let destinationViewController : MapViewController = segue.destinationViewController as! MapViewController
            
            destinationViewController.imageToDrop = imageCaptured
        }
    }
    
    //Take a still image of the video capture session and overlay the imageView, and store said image
    @IBAction func takePhoto(sender: AnyObject)
    {
        if (self.didTakeImage == false)
        {
            if let videoConnection = self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
            {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                    (sampleBuffer, error) in
                    if sampleBuffer != nil
                    {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider = CGDataProviderCreateWithCFData(imageData)
                        let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                        
                        self.imageCaptured = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                        self.didTakeImage = true
                        self.imageTaken.image = self.imageCaptured
                        self.imageTaken.hidden = false
                    }
                })
            }
            self.sendButton.hidden = false
            self.cancelButton.hidden = false
        }
    }
    
    //Create the image capturing session as the view is coming into view
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do{
            let input = try AVCaptureDeviceInput(device: backCamera)
            if self.captureSession?.canAddInput(input) == true
            {
                self.captureSession?.addInput(input)
                self.stillImageOutput = AVCaptureStillImageOutput()
                self.stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if self.captureSession?.canAddOutput(stillImageOutput) == true
                {
                    self.captureSession?.addOutput(stillImageOutput)
                    
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    self.previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                    self.cameraView.layer.addSublayer(self.previewLayer!)
                    captureSession?.startRunning()
                }
            }
            
        } catch
        {
            print("Input device fucked up")
        }
        
    }
}
