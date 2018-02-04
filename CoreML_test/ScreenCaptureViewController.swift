//
//  ScreenCaptureViewController.swift
//  CoreML_test
//
//  Created by kochiai on 6/16/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit

class ScreenCaptureViewController: UIViewController {
    
    fileprivate struct Constant {
        static let pridictTimeInterval: TimeInterval = 1.0
        static let numOfPrediction: Int = 9
        static let initialWebsite = "https://images.google.com"
        static let modelPickerSegueName = "modelPickerSegue"
    }
    
    enum ImageSource: Int {
        case browser
        case camera
    }
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var cameraOutPreviewView: UIView!
    @IBOutlet weak var imageSourceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var predictionLabel: UILabel!
    
    fileprivate var cameraImageCapture: VideoCapture!
    fileprivate var currentModel: ImageClassificationModel = ImageMlModel.Inception.mlmodel
    
    fileprivate var currentImageSource: ImageSource {
        return ImageSource(rawValue:imageSourceSegmentedControl.selectedSegmentIndex)!
    }
    fileprivate var timer: Timer!
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: Constant.pridictTimeInterval,
                                     target: self,
                                     selector: #selector(predict),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        predict(sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.modelPickerSegueName {
            let modelPickerViewController = segue.destination as? MlModelPickerViewController
            modelPickerViewController?.currentModel = currentModel
            modelPickerViewController?.delegate = self
        }
    }
    
    // MARK: IBAction
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        updateImageSourceView()
    }
    
    // MARK: private methods
    
    fileprivate func setup() {
        switch (currentImageSource) {
        case .browser:
            webView.loadRequest(URLRequest(url: URL(string:Constant.initialWebsite)!))
            cameraImageCapture?.stopCapture()
            
        case .camera:
            setupCameraCapture()
            cameraImageCapture.startCapture()
        }
        updateImageSourceView()
    }
    
    fileprivate func setupCameraCapture() {
        if cameraImageCapture == nil {
            cameraImageCapture = VideoCapture(cameraType: .back,
                                              preferredSpec: VideoSpec(fps: 3, size: currentModel.inputImageSize),
                                              previewContainer: cameraOutPreviewView.layer)
        }
    }
    
    fileprivate func updateImageSourceView() {
        switch (currentImageSource) {
        case .browser:
            webView.isHidden = false
            cameraOutPreviewView.isHidden = true
            cameraImageCapture?.stopCapture()
            
        case .camera:
            webView.isHidden = true
            cameraOutPreviewView.isHidden = false
            setupCameraCapture()
            cameraImageCapture.startCapture()
        }
    }
    
    @objc fileprivate func predict(sender: Any) {
        guard let image = getPixelBufferToPredict() else {
            debugPrint("getImageFromLayer returned nil")
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let `self` = self else {
                return
            }
            do {
                let pred: [String : Double] = try self.currentModel.prediction(image: image)
                
                let predictionText = pred.sorted {
                    $0.value > $1.value
                    }[0..<self.numOfPredictionUpperBound(predCount: pred.count)].reduce("", { (result, arg1) -> String in
                        let (label, prob) = arg1
                        let prediction = result + "\(label) - \(String(format: "%.1f", prob * 100))%\n"
                        print(prediction)
                        return prediction
                    })
                let textToShow = "\"\(self.currentModel.name)\" prediction result \n\(predictionText)"
                DispatchQueue.main.async { [weak self] in
                    self?.predictionLabel.text = textToShow
                }
            } catch {
                fatalError("Unexpected error ocurred: \(error.localizedDescription).")
            }
        }
    }
    
    private func numOfPredictionUpperBound(predCount: Int) -> Int {
        if predCount > 9 {
            return 9
        }
        else {
            return predCount
        }
    }
    
    fileprivate func getPixelBufferToPredict()-> CVPixelBuffer?{
        switch (currentImageSource) {
        case .browser:
            let buf = pixelBufferFromLayer(layer: webView.layer)!
            return resize(imageBuffer: buf, to: currentModel.inputImageSize)
        case .camera:
            guard let buffer = cameraImageCapture.currentPixelBuffer else {
                return nil
            }
            return resize(imageBuffer:buffer , to: currentModel.inputImageSize)
        }
    }
    
    fileprivate func pixelBufferFromLayer(layer: CALayer) -> CVPixelBuffer? {
        // Get CIImage out of CALayer
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let cgImage = UIGraphicsGetCurrentContext()?.makeImage()
        UIGraphicsEndImageContext()
        
        // Creating CVPixelBuffer
        var buffer: CVPixelBuffer?
        let ciImage = CIImage(cgImage: cgImage!)
        let scaleFactor = UIScreen.main.scale
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(layer.bounds.size.width * scaleFactor),
                            Int(layer.bounds.size.height * scaleFactor),
                            kCVPixelFormatType_32BGRA ,
                            nil, &buffer)
        CIContext().render(ciImage, to: buffer!)
        return buffer
    }
    
    func resize(imageBuffer: CVPixelBuffer, to size: CGSize) -> CVPixelBuffer? {
        var ciImage = CIImage(cvPixelBuffer: imageBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: size.width / CGFloat(CVPixelBufferGetWidth(imageBuffer)), y: size.height / CGFloat(CVPixelBufferGetHeight(imageBuffer)))
        ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA , nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }
}

extension ScreenCaptureViewController: MlModelPickerViewControllerDelegate {
    func didSelectModel(modelPickerViewController: MlModelPickerViewController, selectedModel: ImageClassificationModel) {
        currentModel = selectedModel
    }
}
