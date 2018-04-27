//
//  QRViewController.swift
//  discord
//
//  Created by Ke Li on 4/21/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var index: Int!
    var proxy: Proxy!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBAction func onBackButtonClicked(_ sender: Any) {
        if let _ = self.presentingViewController {
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        if let validCaptureDevice = captureDevice {
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: validCaptureDevice)
                
                // Initialize the captureSession object.
                captureSession = AVCaptureSession()
                
                // Set the input device on the capture session.
                captureSession.addInput(input)
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

            } catch {
                // If any error occurs, simply print it out and don't continue any more.
                print(error)
                return
            }
        } else {
            self.messageLabel.text = "Can't get video access"
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: navigationBar)
        captureSession.startRunning()
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                guard let jsonData = metadataObj.stringValue!.data(using: .utf8) else {
                    messageLabel.text = "maybe the encoding is wrong, don't know how to handle"
                    return
                }
                // we have a string value here, check if it's json string or not
                if isValidUrl(urlString: metadataObj.stringValue!){
                    messageLabel.text = metadataObj.stringValue!
                    self.proxy = Proxy()
                    self.proxy.pacUrl = metadataObj.stringValue!
                } else {
                    // maybe it's a json and we can have it processed!
                    do {
                        self.proxy = try JSONDecoder().decode(Proxy.self, from: jsonData)
                    } catch {
                        messageLabel.text = "not a valid JSON object, nor a valid url"
                        return
                    }
                }
                let activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                activityView.center = self.view.center
                activityView.startAnimating()
                self.view.addSubview(activityView)
                self.view.isUserInteractionEnabled = false
                self.captureSession.stopRunning()
                messageLabel.text = "processing"
                validateAndDownload(item: self.proxy) { (result) in
                    self.view.isUserInteractionEnabled = true
                    self.view.willRemoveSubview(activityView)
                    activityView.stopAnimating()
                    
                    switch result {
                    case .warning:
                        // since we know warning won't be a problem of usage, we just alert user and told them the pac image isn't working well and go on.
                        let alert = UIAlertController(title: "Opps, the url to image may have problem", message: "but that won't affect your use", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                            self.goback()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    case .ok:
                        self.goback()
                    case .error:
                        let alert = UIAlertController(title: "Opps, something went wrong", message: "check your input please", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                            self.captureSession.startRunning()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func goback() {
        if let tempViewController = self.presentingViewController as? ViewController {
            // pass back change from here.
            tempViewController.callbackFromOtherVC(index: self.index, item: self.proxy)
            self.presentingViewController!.dismiss(animated: true) {
                self.captureSession.startRunning()
            }

        }
    }
}



