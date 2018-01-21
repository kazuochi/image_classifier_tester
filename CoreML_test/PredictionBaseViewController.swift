//
//  PredictionBaseViewController.swift
//  CoreML_test
//
//  Created by kochiai on 6/15/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit

class PredictionBaseViewController: UIViewController {
    
    @IBOutlet weak var modelSwitcher: UISegmentedControl!
    @IBOutlet weak var predictionLabel: UILabel!
    var currentModel = ImageMlModel()
    
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
