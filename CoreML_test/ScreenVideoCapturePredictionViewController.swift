//
//  ScreenVideoCapturePredictionViewController.swift
//  CoreML_test
//
//  Created by kochiai on 6/15/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit
import ReplayKit
import AVFoundation

class ScreenVideoCapturePredictionViewController: PredictionBaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadModel()
        webView.loadRequest(URLRequest(url: URL(string:"https://www.google.com")!))
    }
    
    @IBAction func modelValueChanged(_ sender: UISegmentedControl) {
        RPScreenRecorder.shared().stopCapture { [weak self] (error) in
            print("error occured \(error.debugDescription)")
            guard error == nil,
                let `self` = self else {
                    return
            }
            
            guard let imageMlMode = ImageMlModel.MlModels(rawValue: sender.selectedSegmentIndex) else {
                assert(false, "imageMlMode is nil")
                return
            }
            self.currentModel = ImageMlModel(imageModel: imageMlMode)
            
            self.reloadModel()
       }
    }
    
    func reloadModel() {
        RPScreenRecorder.shared().startCapture(handler: { [weak self] (sampleBuffer: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) in
            guard bufferType == .video else {
                return
            }
            
            guard let `self` = self,
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
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
                            let prediction = result + "\(label) - \(String(format: "%.1f", prob * 100))% "
                            print(prediction)
                            return prediction
                        })
                }
            }
            catch let error as NSError {
                fatalError("Unexpected error ocurred: \(error.localizedDescription).")
            }
        }) { (error) in
            print("error \(error.debugDescription)")
            // completion block
            ()
        }
    }
}
