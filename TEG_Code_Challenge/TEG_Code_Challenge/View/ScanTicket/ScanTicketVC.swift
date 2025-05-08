//
//  ScanTicketVC.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import UIKit
import RxSwift
import RxCocoa

class ScanTicketVC: UIViewController {
    
    let viewModel = ScanTicketVM()
    
    lazy var cameraView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var loadingLbl:UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .white
        lbl.text = "Loading Camera"
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        rxBuild()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let `self` = self else { return }
            // Will create hole on the UIView
            self.cameraView.createHoleInMiddle { [weak self] rect in
                guard let `self` = self else { return }
                // will only check bar code from the center hole
                self.viewModel.configureRectOfInterest(bounds: rect)
            }
        }
    }
    
    // adjust exposure and focus of the camera when tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first,
           let device = viewModel.videoInput?.device
        {
            let screenSize = cameraView.bounds.size
            let focusPoint = CGPoint(x: touchPoint.location(in: cameraView).y / screenSize.height, y: 1.0 - touchPoint.location(in: cameraView).x / screenSize.width)
            
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                
                device.unlockForConfiguration()
            } catch {
                viewModel.errorMessage.onNext((title: "Error Auto-focus", message: "There is an error on auto focus"))
            }
        }
    }
}

// MARK: Private
extension ScanTicketVC {
    private func setupLayout() {
        view.addSubview(cameraView)
        
        cameraView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        cameraView.addSubview(loadingLbl)
        
        loadingLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func rxBuild() {
        viewModel
            .isCameraReady
            .bind { [weak self] isReady in
                guard let `self` = self else { return }
                
                if !isReady {
                    self.loadingLbl.isHidden = false
                    return
                }
                
                self.loadingLbl.isHidden = true
                guard let previewLayer = self.viewModel.previewLayer else { return }
                previewLayer.frame = self.view.layer.bounds
                self.cameraView.layer.addSublayer(previewLayer)
                
                self.viewModel.startCapture()
            }.disposed(by: rx.disposeBag)
        
        viewModel
            .errorMessage
            .bind { [weak self] tuple in
                guard let `self` = self else { return }
                self.viewModel.showErrorAlert(title: tuple.title, message: tuple.message)
            }.disposed(by: rx.disposeBag)
        
        viewModel
            .presentState
            .bind { [weak self] view in
                guard let `self` = self else { return }
                self.present(view, animated: true)
            }.disposed(by: rx.disposeBag)
    }
}
