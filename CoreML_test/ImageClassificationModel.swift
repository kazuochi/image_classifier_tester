//
//  ImageClassificationModel.swift
//  CoreML_test
//
//  Created by Kazuhito Ochiai on 2/4/2018.
//  Copyright © 2018 kochiai. All rights reserved.
//

import UIKit
import CoreML

protocol ImageClassificationModel {
    var model: MLModel { get }
    var inputImageSize: CGSize { get }
    var name: String { get }
    var description: String { get }
    func prediction(image: CVPixelBuffer) throws -> [String : Double]
}

extension ImageClassificationModel {
    var name: String {
        return String(describing: self)
    }
    
    var description: String {
        guard let modelDescription = self.model.modelDescription.metadata[MLModelMetadataKey.description] as? String,
        !modelDescription.isEmpty else {
            return "No description available"
        }
        return modelDescription
    }
}
