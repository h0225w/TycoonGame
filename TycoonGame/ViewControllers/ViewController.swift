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
        
        createSkewer()
        
        createGrillThread(at: 0) // 0번째 불판
        createGrillThread(at: 1)
        createGrillThread(at: 2)
    }
    
    // MARK: 불판에 올라간 꼬치 상태 업데이트
    private func grillStatusUpdate(at: Int, _ data: Grill) -> Bool {
        var isRunning: Bool
        
        switch data.status {
        case .raw:
            print("😀 \(data.skewer.type) 꼬치가 맛있게 익었어요 !!!")
            self.grillModel.update(at: at, Grill(status: .roast, skewer: data.skewer))
            isRunning = true
            break
        case .roast:
            print("😥 \(data.skewer.type) 이런 꼬치가 다 타버렸어요 !!!")
            self.grillModel.update(at: at, Grill(status: .burnt, skewer: data.skewer))
            isRunning = false
            break
        case .burnt:
            isRunning = false
        }
        
        return isRunning
    }
    
    // MARK: 꼬치 생성 (떡꼬치, 닭꼬치, 양꼬치)
    private func createSkewer() {
        skewerModel.create(Skewer(type: .ricecake, time: 5, price: 500, count: 0))
        skewerModel.create(Skewer(type: .chicken, time: 7, price: 1500, count: 0))
        skewerModel.create(Skewer(type: .lamb, time: 10, price: 3000, count: 0))
    }
    
    // MARK: 불판 스레드 생성
    private func createGrillThread(at: Int) {
        guard let skewer = skewerModel.read(at: at) else { return }
        
        grillModel.create(Grill(status: .raw, skewer: skewer))
        
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: TimeInterval(skewer.time), repeats: true) { _ in
                guard let grill = self.grillModel.read(at: at) else { return }
                
                isRunning = self.grillStatusUpdate(at: at, grill)
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.5))
            }
        }
    }
}

