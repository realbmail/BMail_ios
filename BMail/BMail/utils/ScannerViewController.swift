//
//  ScannerViewController.swift
//  Pirate
//
//  Created by hyperorchid on 2020/2/29.
//  Copyright © 2020 hyperorchid. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScannerViewControllerDelegate {
        func codeDetected(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var delegate:ScannerViewControllerDelegate?
        @IBOutlet weak var ScanAreaView: UIImageView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                captureSession = AVCaptureSession()

                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
                let videoInput: AVCaptureDeviceInput
                do {
                        videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                        return
                }

                if (captureSession.canAddInput(videoInput)) {
                        captureSession.addInput(videoInput)
                } else {
                        failed()
                        return
                }

                let metadataOutput = AVCaptureMetadataOutput()

                if (captureSession.canAddOutput(metadataOutput)) {
                        captureSession.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                } else {
                        failed()
                        return
                }
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.cornerRadius = 16
                previewLayer.frame = CGRect(origin: CGPoint(x: 2,y: 2), size: CGSize(width:228, height: 228))
                previewLayer.videoGravity = .resizeAspectFill
                self.ScanAreaView.layer.addSublayer(previewLayer)

                captureSession.startRunning()
        }

        func failed() {
                let ac = UIAlertController(title: "Scanning not supported".locStr, message:
                        "Your device does not support scanning a code from an item. Please use a device with a camera.".locStr,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK".locStr, style: .default))
                present(ac, animated: true)
                captureSession = nil
        }

        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)

                if (captureSession?.isRunning == false) {
                        captureSession.startRunning()
                }
        }

        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)

                if (captureSession?.isRunning == true) {
                        captureSession.stopRunning()
                }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                captureSession.stopRunning()

                if let metadataObject = metadataObjects.first {
                        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                        guard let stringValue = readableObject.stringValue else { return }
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.delegate?.codeDetected(code: stringValue)
                }

                dismiss(animated: true)
        }

        override var prefersStatusBarHidden: Bool {
                return true
        }

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
                return .portrait
        }
        
        @IBAction func Cancel(_ sender: Any) {
                dismiss(animated: true, completion: nil)
        }
}
