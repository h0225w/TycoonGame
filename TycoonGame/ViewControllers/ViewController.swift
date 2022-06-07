//
//  ViewController.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/05.
//

import UIKit

class ViewController: UIViewController {
    let skewer = SkewerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skewer.create(Skewer(type: .ricecake, time: 5, price: 500, count: 0))
        skewer.create(Skewer(type: .chicken, time: 7, price: 1500, count: 0))
        skewer.create(Skewer(type: .lamb, time: 10, price: 3000, count: 0))
        
    }


}

