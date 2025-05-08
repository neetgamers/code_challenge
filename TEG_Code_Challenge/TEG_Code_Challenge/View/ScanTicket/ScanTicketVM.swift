//
//  ScanTicketVM.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation
import UIKit
import RxSwift
import AVFoundation

class ScanTicketVM:NSObject {
    
    private let captureSessionQueue = DispatchQueue(label: "capture-session-serial-queue")
    
    var venue = BehaviorSubject<VenueModel?>(value: nil)
    
    var presentState = PublishSubject<UIViewController>()
    
    var captureSesssion:AVCaptureSession?
    var previewLayer:AVCaptureVideoPreviewLayer?

    var errorMessage = PublishSubject<(title:String, message:String)>()
    var isCameraReady = BehaviorSubject<Bool>(value: false)
    
    var videoInput:AVCaptureDeviceInput?
    var metadataOutput = AVCaptureMetadataOutput()
    var metaDataTypes:[AVMetadataObject.ObjectType] = [
        .ean13,
        .ean8,
        .upce,
        .code39,
        .code39Mod43,
        .code93,
        .code128,
        .pdf417,
        .itf14,
        .interleaved2of5,
        .aztec,
        .qr
    ]
    
    private let venueService = TEGVenueService(client: SecureAPIClient())
    
    override init() {
        super.init()
        initCaptureSession()
    }
    
    private func initCaptureSession() {
        captureSesssion = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed(title: "Initialization failed", message: "Capture device initialization failed.")
            return
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            // Automatically adjust the exposure of the video
            if let vi =  videoInput, vi.device.isExposurePointOfInterestSupported {
                try vi.device.lockForConfiguration()
                vi.device.exposureMode = .continuousAutoExposure
                vi.device.unlockForConfiguration()
            }
        } catch {
            failed(title: "Initialization failed", message: "Capture device input initialization failed.")
            return
        }
        
        if let vidInput = videoInput, let _capSession = captureSesssion {
            _capSession.canAddInput(vidInput)
            _capSession.addInput(vidInput)
        } else {
            failed()
            return
        }
        
        if let _capSession = captureSesssion, _capSession.canAddOutput(metadataOutput) {
            _capSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            if #available(iOS 15.4, *) {
                // Additional type of barcode that is only available on iOS 15.4 or later
                metaDataTypes.append(contentsOf: [
                    .gs1DataBar,
                    .gs1DataBarLimited,
                    .gs1DataBarExpanded,
                    .codabar
                ])
            }
            
            metadataOutput.metadataObjectTypes = metaDataTypes
            
            previewLayer = AVCaptureVideoPreviewLayer(session: _capSession)
            previewLayer?.videoGravity = .resizeAspectFill
            isCameraReady.onNext(true)
        } else {
            failed()
            return
        }
    }
    
    // Will only check the bar code from the center hole of the view
    func configureRectOfInterest(bounds:CGRect) {
        if let roi = previewLayer?.metadataOutputRectConverted(fromLayerRect: bounds) {
            metadataOutput.rectOfInterest = roi
        }
    }
    
    // Start capture of the video for scan
    func startCapture(reRun:Bool = false) {
        guard let captureSession = self.captureSesssion else { return }
        captureSessionQueue.asyncAfter(deadline: .now(), qos: .background) { [weak self] in
            guard let `self` = self else { return }
            captureSession.startRunning()
            
            if reRun {
                do {
                    if let vi = self.videoInput, vi.device.isExposurePointOfInterestSupported {
                        try vi.device.lockForConfiguration()
                        vi.device.exposureMode = .continuousAutoExposure
                        vi.device.unlockForConfiguration()
                    }
                } catch { }
            }
        }
    }
}

extension ScanTicketVM {
    private func failed(
        title:String = "Scanning not supported",
        message:String = "Your device does not support scanning a code. Please use a device with a camera."
    ) {
        errorMessage.onNext((title: title, message: message))
    }
}

extension ScanTicketVM: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            if let captureSession = self.captureSesssion, captureSession.isRunning {
                // Stop the capture session to ensure that it won't continuously get the same bar code
                captureSession.stopRunning()
                
                // Validate the ticket
                self.beginValidateTicket(code: stringValue)
            }
        }
    }
}

extension ScanTicketVM {
    private func beginValidateTicket(code:String) {
        guard let venue = try? venue.value() else { return }
        Task {
            guard let result = try? await venueService.scanTicket(code: venue.code, barcode:code) else { return }
            
            // It will just push the result to the next screen, to display appropriate layout.
            // If sucess and valid it will display the a big green check mark icon and display the status message, else display big red x mark icon if in valid.
            
            switch result {
            case .success(let result):
                print(result)
                await MainActor.run {
                    // No time to create a new screen to display validation of ticket
                    // For now I just display an alert success and once hit `Okay` button it will restart capturing the camera.
                    self.showSuccessAlert(title: result.result, message: "\(code)\n\n\(result.status)")
                }
            case .failure(let error):
                await MainActor.run {
                    self.showErrorAlert(title: "Error", message: error.errorDescription)
                }
            }
        }
    }
}

// MARK: Alerts
extension ScanTicketVM {
    func showSuccessAlert(title:String, message:String, btnName:String = "Okay") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnName, style: .default, handler: { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else { return }
                self.startCapture(reRun: true)
            }
        }))
        presentState.onNext(alert)
    }
    
    func showErrorAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        presentState.onNext(alert)
    }
}

extension Reactive where Base: ScanTicketVM {
    
}
