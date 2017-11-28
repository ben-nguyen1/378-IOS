//
//  TransactionViewController.swift
//  BuildABudget
//
//  Created by chris on 11/28/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import Foundation
import UIKit

protocol ExportDelegate: class {
    func exportMyData( callingUIViewController: UIViewController)
}

class TransactionViewController: UIViewController {
    
    let exporter = Export.transferAgent
    weak var delegate:ExportDelegate?
    
    @IBAction func exportButton(_ sender: Any) {
        print(">>>TRANSACTIONSVC: startig exporting csv")
        let thisVC:UIViewController = self
        exporter.exportMyData( callingUIViewController: thisVC)
        
        //delegate?.exportMyData( callingUIViewController: thisVC)
        print(">>>TRANSACTIONSVC: finished exporting csv")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}


