//
//  ImageMlModel.swift
//  CoreML_test
//
//  Created by kochiai on 6/14/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit
import CoreML

enum ImageMlModel: Int {
    case GoogLeNet
    case Inception
    case Resnet
    case VGG
    case Cat_Or_Dog
    case Food101
    static var count: Int { return self.Food101.hashValue + 1}
    
    var mlmodel: ImageClassificationModel {
        switch self {
        case .GoogLeNet:
            return ImageMlModel.googLeNetPlaces
        case .Inception:
            return ImageMlModel.inceptionv3
        case .Resnet:
            return ImageMlModel.resnet50
        case .VGG:
            return ImageMlModel.vgg16
        case .Cat_Or_Dog:
            return ImageMlModel.catOrDog
        case .Food101:
            return ImageMlModel.food_101
        }
    }
    
    static let googLeNetPlaces = GoogLeNetPlaces()
    static let inceptionv3 = Inceptionv3()
    static let resnet50 = Resnet50()
    static let vgg16 = VGG16()
    static let catOrDog = CatOrDog()
    static let food_101 = Food_101()
}


extension GoogLeNetPlaces: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 224, height: 224)
    }
    
    var name: String {
        return "Places205-GoogLeNet"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return try prediction(sceneImage: image).sceneLabelProbs
    }
}


extension Inceptionv3: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 299, height: 299)
    }
    
    var name: String {
        return "Inception v3"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return  try prediction(image: image).classLabelProbs
    }
}


extension Resnet50: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 224, height: 224)
    }
    
    var name: String {
        return "ResNet50"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return try prediction(image: image).classLabelProbs
    }
}


extension VGG16: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 224, height: 224)
    }
    
    var name: String {
        return "VGG16"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return try prediction(image: image).classLabelProbs
    }
}


extension CatOrDog: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    var name: String {
        return "CatOrDog"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return try prediction(image: image).classLabelProbs
    }
}


extension Food_101: ImageClassificationModel {
    var inputImageSize: CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    var name: String {
        return "Food101"
    }
    
    func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        return try prediction(image: image).classLabelProbs
    }
}
