//
//  MlModelPickerViewController.swift
//  CoreML_test
//
//  Created by kochiai on 6/17/17.
//  Copyright © 2017 kochiai. All rights reserved.
//

import UIKit


protocol MlModelPickerViewControllerDelegate: class {
    func didSelectModel(modelPickerViewController:MlModelPickerViewController, selectedModel:ImageMlModel)
}

class MlModelPickerViewController: UITableViewController {
    
    weak var delegate: MlModelPickerViewControllerDelegate?
    
    lazy var models: [ImageMlModel] = {
        return (0..<ImageMlModel.MlModels.count).reduce([ImageMlModel](), { (result, rawValue) in
            var models = result
            guard let model =  ImageMlModel(rawValue: rawValue) else {
                fatalError("ImageMlModel could not initialized")
            }
            models.append(model)
            return models
        })
    }()
    
    var currentModel: ImageMlModel! = ImageMlModel(rawValue:2)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelCell")!
        let row = indexPath.row
        cell.textLabel?.text = models[row].name
        cell.detailTextLabel?.text = models[row].description
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.accessoryType = models.index{ $0 == currentModel } == row ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        delegate?.didSelectModel(modelPickerViewController: self, selectedModel: models[row])
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
