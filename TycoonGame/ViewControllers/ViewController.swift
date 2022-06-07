//
//  ViewController.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/05.
//

import UIKit

class ViewController: UIViewController {
    let skewerModel = SkewerModel()
    let grillModel = GrillModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skewerModel.create(Skewer(type: .ricecake, time: 5, price: 500, count: 0))
        skewerModel.create(Skewer(type: .chicken, time: 7, price: 1500, count: 0))
        skewerModel.create(Skewer(type: .lamb, time: 10, price: 3000, count: 0))
        
        grillModel.create(Grill(status: .raw, skewer: .ricecake))
        grillModel.create(Grill(status: .raw, skewer: .chicken))
        grillModel.create(Grill(status: .raw, skewer: .lamb))
        
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                guard let grill = self.grillModel.read(at: 0) else { return }
                
                isRunning = self.grillStatusUpdate(at: 0, grill)
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(1))
            }
        }
        
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { _ in
                guard let grill = self.grillModel.read(at: 1) else { return }
                
                isRunning = self.grillStatusUpdate(at: 1, grill)
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(1))
            }
        }
        
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                guard let grill = self.grillModel.read(at: 2) else { return }
                
                isRunning = self.grillStatusUpdate(at: 2, grill)
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(1))
            }
        }
    }
    
    // MARK: 불판에 올라간 꼬치 상태 업데이트
    private func grillStatusUpdate(at: Int, _ data: Grill) -> Bool {
        var isRunning: Bool
        
        switch data.status {
        case .raw:
            print("😀 \(at)번째 꼬치가 맛있게 익었어요 !!!")
            self.grillModel.update(at: at, Grill(status: .roast, skewer: data.skewer))
            isRunning = true
            break
        case .roast:
            print("😥 \(at)번째 이런 꼬치가 다 타버렸어요 !!!")
            self.grillModel.update(at: at, Grill(status: .burnt, skewer: data.skewer))
            isRunning = false
            break
        case .burnt:
            isRunning = false
        }
        
        return isRunning
    }
}

