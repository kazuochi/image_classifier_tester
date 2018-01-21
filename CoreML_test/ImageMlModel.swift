//
//  ImageMlModel.swift
//  CoreML_test
//
//  Created by kochiai on 6/14/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit

struct ImageMlModel {
    enum MlModels: Int {
        case GoogLeNet
        case Inception
        case Resnet
        case VGG
        case CatOrDog
        case Food101
        static var count: Int { return MlModels.Food101.hashValue + 1}
    }
    
    fileprivate let imageModel: MlModels
    
    // Actual mlmodel object is created lazily
    fileprivate lazy var googlenet = { GoogLeNetPlaces() }()
    fileprivate lazy var inception = { Inceptionv3() }()
    fileprivate lazy var resnet = { Resnet50() }()
    fileprivate lazy var vgg = { VGG16() }()
    fileprivate lazy var catOrDog = { CatOrDog() }()
    fileprivate lazy var food101 = { Food_101() }()

    init() {
        imageModel = .GoogLeNet
    }
    
    init(imageModel: MlModels){
        self.imageModel = imageModel
    }
    
    init?(rawValue: Int) {
        guard let model = MlModels(rawValue: rawValue) else {
            return nil
        }
        imageModel = model
    }
    
    var numOfModelType: Int {
        return MlModels.count
    }
    
    /// Expected input image size
    var inputImageSize: CGSize{
        switch (imageModel) {
        case .GoogLeNet:
            return CGSize(width: 224, height: 224)
        case .Inception:
            return  CGSize(width: 299, height: 299)
        case .Resnet:
            return CGSize(width: 224, height: 224)
        case .VGG:
            return CGSize(width: 224, height: 224)
        case .CatOrDog:
            return CGSize(width: 150, height: 150)
        case .Food101:
            return CGSize(width: 150, height: 150)
        }
    }
    
    var name: String {
        switch (imageModel) {
        case .GoogLeNet:
            return  "Places205-GoogLeNet"
        case .Inception:
            return "Inception v3"
        case .Resnet:
            return "ResNet50"
        case .VGG:
            return "VGG16"
        case .CatOrDog:
            return "CatOrDog"
        case .Food101:
            return "Food101"
        }
    }
    
    var description: String {
        switch (imageModel) {
        case .GoogLeNet:
            return  "Detects the scene of an image from 205 categories such as an airport terminal, bedroom, forest, coast, and more."
        case .Inception:
            return "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."
        case .Resnet:
            return "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."
        case .VGG:
            return "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."
        case .CatOrDog:
            return "Classifies cat or dog"
        case .Food101:
            return "Classifies food items from 101 categories"
        }
    }
    
    var numOfPredictionUpperBound: Int {
        switch (imageModel) {
        case .CatOrDog:
            return 2
        case .GoogLeNet,
         .Inception,
         .Resnet,
         .VGG,
         .Food101:
            return 9
        }
    }
    
    mutating func prediction(image: CVPixelBuffer) throws -> [String : Double] {
        switch (imageModel) {
        case .GoogLeNet:
            return  try googlenet.prediction(sceneImage: image).sceneLabelProbs
        case .Inception:
            return  try inception.prediction(image: image).classLabelProbs
        case .Resnet:
            return try resnet.prediction(image: image).classLabelProbs
        case .VGG:
            return try vgg.prediction(image: image).classLabelProbs
        case .CatOrDog:
            let prediction = try catOrDog.prediction(image: image).classLabelProbs
            let dogProbability = prediction["dog"]!
            return [
                "dog" : dogProbability,
                "cat" : 1 - dogProbability
            ]
        case .Food101:
            return try food101.prediction(image: image).classLabelProbs
        }
    }
}

extension ImageMlModel: Equatable {
    static func ==(lhs: ImageMlModel, rhs: ImageMlModel) -> Bool{
        return lhs.imageModel == rhs.imageModel
    }
}
