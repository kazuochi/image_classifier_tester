//
//  CameraPredictionViewController.swift
//  CoreML_test
//
//  Created by kochiai on 6/10/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit

class CameraPredictionViewController: PredictionBaseViewController {
    
    fileprivate var videoCapture: VideoCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVideoCapture()
        reloadModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {
            return
        }
        videoCapture.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {
            return
        }
        videoCapture.resizePreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {
            return
        }
        videoCapture.stopCapture()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    // MARK: IBAction
    
    @IBAction func modelValueChanged(_ sender: UISegmentedControl) {
        videoCapture.stopCapture()
        videoCapture.cleanPreviousSession()
        initializeVideoCapture()
        guard let imageMlMode = ImageMlModel.MlModels(rawValue: sender.selectedSegmentIndex) else {
            assert(false, "imageMlMode is nil")
            return
        }
        currentModel = ImageMlModel(imageModel: imageMlMode)
        reloadModel()
        videoCapture.startCapture()
    }
    
    // MARK: private methods
    
    fileprivate func initializeVideoCapture() {
        let size = currentModel.inputImageSize
        let spec = VideoSpec(fps: 3, size: size)
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: view.layer)
    }
    
    fileprivate func reloadModel() {
        videoCapture.imageBufferHandler = { [weak self] (imageBuffer, timestamp, outputBuffer) in
            guard let `self` = self else {
                return
            }
            
            let size = self.currentModel.inputImageSize
            guard let resizedImage = self.resize(imageBuffer: imageBuffer, to: size) else {
                assert(false, "resizedImage was nil")
                return
            }
            do {
                let prediction = try self.currentModel.prediction(image: resizedImage)
                DispatchQueue.main.async {
                    self.predictionLabel.text = prediction.sorted {
                        $0.value > $1.value
                        }[0...3].reduce("", { (result, arg1) -> String in
                            let (label, prob) = arg1
                            return result + "\(label) - \(String(format: "%.1f", prob * 100))% "
                        })
                }
            }
            catch let error as NSError {
                fatalError("Unexpected error ocurred: \(error.localizedDescription).")
            }
        }
    }
}

