//
//  CameraVC.swift
//  Scan
//
//  Created by Neil Sood on 9/18/18.
//  Copyright © 2018 Neil Sood. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import AVFoundation

class CameraVC: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    
    
//    var delegate: WalmartItemDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tableData: [Product] = []
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
//        delegate = self
        

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        barCodeFrameView = UIView()
        
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.layer.borderColor = UIColor.green.cgColor
            barCodeFrameView.layer.borderWidth = 2
            view.addSubview(barCodeFrameView)
            view.bringSubview(toFront: barCodeFrameView)
        }
    }
    
    func launchApp(decodedURL: String) {
        var new_url = decodedURL
        
        new_url.remove(at: new_url.startIndex)
        
        if presentedViewController != nil {
            return
        }

        let alertPrompt = UIAlertController(title: "Product", message: "Are you sure you're looking for \(new_url)?", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        
            print("I'm here")
            if let url = URL(string: new_url) {
              if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                self.searchBy(itemUPC: new_url) {_ in
                        //print(new_url)
                }
                }
            }
        })
    
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)

        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
//        dismiss(animated: true, completion: nil)
    
        present(alertPrompt, animated: true, completion: nil)
    }
    
    let basePath = "http://api.walmartlabs.com/v1/items?apiKey=cfrtyy57xvbyu2z5u8sr2mqq&upc="
    
    func searchBy(itemUPC upc: String, completion: @escaping ([WalmartItem]) -> ()) {
        
        let url = "\(basePath)\(upc)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            //            var delegate: WalmartItemDelegate?
            if let data = data {
                do {
                    // converts JSONformat to dictionary
                    // if this serialization works we need to access the object based on the format of the data (dictionary)
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let allItems = json["items"] as? [[String:Any]] {
                            let data = allItems[0]
//                            print(allItems[0])
                            //                            print(delegate)
                            let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: self.context) as! Product
                            product.name = data["name"] as! String
                            product.brand = data["brandName"] as! String
                            product.isFavorited = false
                            product.price = data["salePrice"] as! Double
                            product.upc = data["upc"] as! String
                            
                            self.tableData.insert(product, at: 0)
                            
                            do {
                                try self.context.save()
                                print("SAVED")
                            } catch {
                                print("\(error)")
                            }                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        task.resume()
    }
}

extension CameraVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {


                launchApp(decodedURL: metadataObj.stringValue!)
//                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}

