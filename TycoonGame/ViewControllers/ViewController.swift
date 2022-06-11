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
    let guestModel = GuestModel()
    
    @IBOutlet weak var firstGrillSkewerLabel: UILabel!
    @IBOutlet weak var firstGrillStateLabel: UILabel!
    @IBOutlet weak var firstGrillBtn: UIButton!
    
    @IBOutlet weak var secondGrillSkewerLabel: UILabel!
    @IBOutlet weak var secondGrillStateLabel: UILabel!
    @IBOutlet weak var secondGrillBtn: UIButton!
    
    @IBOutlet weak var thirdGrillSkewerLabel: UILabel!
    @IBOutlet weak var thirdGrillStateLabel: UILabel!
    @IBOutlet weak var thirdGrillBtn: UIButton!
    
    @IBOutlet weak var firstGuestTypeLabel: UILabel!
    @IBOutlet weak var firstGuestStateLabel: UILabel!
    
    @IBOutlet weak var secondGuestTypeLabel: UILabel!
    @IBOutlet weak var secondGuestStateLabel: UILabel!
    
    @IBOutlet weak var thirdGuestTypeLabel: UILabel!
    @IBOutlet weak var thirdGuestStateLabel: UILabel!
    
    
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var salesLabel: UILabel!
    
    @IBOutlet weak var riceCakeSkewerCountLabel: UILabel!
    @IBOutlet weak var chickenSkewerCountLabel: UILabel!
    @IBOutlet weak var lambSkewerCountLabel: UILabel!
    
    var life = 3 // 라이프
    var sales = 0 // 매출액
    
    var riceCakeSkewerCount = 0 // 떡꼬치 개수
    var chickenSkewerCount = 0 // 닭꼬치 개수
    var lambSkewerCount = 0 // 양꼬치 개수
    
    @IBOutlet weak var skewerSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSkewer()
        
        createGuestThread()
    }
    
    // MARK: 불판에 올라간 꼬치 상태 업데이트
    private func grillStateUpdate(at: Int, _ data: Grill) -> Bool {
        var isRunning: Bool
        
        switch data.state {
        case .raw:
            print("😀 \(data.skewer!.type) 꼬치가 맛있게 익었어요 !!!")
            self.grillModel.update(at: at, Grill(state: .roast, skewer: data.skewer))
            isRunning = true
            break
        case .roast:
            print("😥 \(data.skewer!.type) 이런 꼬치가 다 타버렸어요 !!!")
            self.grillModel.update(at: at, Grill(state: .burnt, skewer: data.skewer))
            isRunning = false
            break
        default:
            isRunning = false
        }
        
        return isRunning
    }
    
    // MARK: 꼬치 생성 (떡꼬치, 닭꼬치, 양꼬치)
    private func createSkewer() {
        skewerModel.create(Skewer(type: .ricecake, time: 5, price: 500))
        skewerModel.create(Skewer(type: .chicken, time: 7, price: 1500))
        skewerModel.create(Skewer(type: .lamb, time: 10, price: 3000))
    }
    
    // MARK: 불판 상태 변경에 대한 스레드 생성
    private func createGrillThread(at: Int, skewerAt: Int) {
        guard let skewer = skewerModel.read(at: skewerAt) else { return }
        
        let grill = Grill(state: .raw, skewer: skewer)
        
        if grillModel.read(at: at) != nil {
            if grillModel.update(at: at, grill) {
                print("\(at)번째 불판 재설정")
            }
        } else {
            grillModel.create(grill)
        }
        
        setGrillView(at: at)
        
        // TODO: 불판 재설정 후 요구한 시간 대로 스레드가 동작하지 않는 문제 해결 필요
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: TimeInterval(skewer.time), repeats: true) { _ in
                guard let grill = self.grillModel.read(at: at) else { return }
                
                if grill.state != .empty {
                    isRunning = self.grillStateUpdate(at: at, grill)
                    
                    DispatchQueue.main.async {
                        self.setGrillView(at: at)
                    }
                } else {
                    isRunning = false
                }
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.5))
            }
        }
    }
    
    // MARK: 손님 생성에 대한 스레드 생성
    private func createGuestThread() {
        DispatchQueue.global().async {
            var isRunning = true
            let runLoop = RunLoop.current
            
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                // TODO: 일단 최대 3명까지만 해둠 (추 후 수정 필요)
                if self.guestModel.count >= 3 { isRunning = false }
                else { self.createGuest() }
            }
            
            while isRunning {
                runLoop.run(until: Date().addingTimeInterval(1))
            }
        }
    }
    
    // MARK: 손님 대기 시간에 대한 스레드 생성
    private func createGuestWatingThread(at: Int) -> Bool {
        guard guestModel.count > at else { return false }
        
        guard let guest = guestModel.read(at: at) else { return false }
        
        print("\(at)번째 손님 대기 시간에 대한 스레드 생성 \(guest.time)")
        DispatchQueue.global().asyncAfter(deadline: .now() + guest.time) {
            guard let guest = self.guestModel.read(at: at) else { return }
            
            let data = Guest(type: guest.type, state: .leave, time: guest.time, order: guest.order)
            
            if guest.state != .leave, self.guestModel.update(at: at, data) {
                print("\(at)번째 손님이 떠나버렸어요 ㅜㅜ")
                self.life -= 1
                
                DispatchQueue.main.async {
                    self.setGuestView(at: at)
                    self.lifeLabel.text = "라이프: \(self.life)"
                }

                if (self.life == 0) {
                    print("GAME OVER !!!")
                }
            }
        }
        
        return true
    }
    
    // MARK: 손님 생성
    private func createGuest() {
        let type = GuestType.allCases.randomElement()! // 손님 종류 랜덤값
        let order = setOrder()
        let watingTime = setGuestWatingTime(type, order: order) // 대기 시간
        
        print("type: \(type), order: \(order), watingTime: \(watingTime)")
        guestModel.create(Guest(type: type, state: .waiting, time: watingTime, order: order))
        
        let at = guestModel.count - 1
        
        DispatchQueue.main.async {
            self.setGuestView(at: at)
        }
        
        if !createGuestWatingThread(at: at) {
            print("손님 대기 시간에 대한 스레드 생성 실패")
        }
    }
    
    // MARK: 손님 주문 내역 설정
    private func setOrder() -> [Int]{
        var order: [Int] = []
        
        for _ in 0 ..< skewerModel.count {
            let count = Int.random(in: 0 ... 1)
            order.append(count)
        }
        
        // 모든 꼬치의 주문 개수가 0일 때
        if (order == [0, 0, 0]) {
            order[Int.random(in: 0 ..< skewerModel.count)] = 1
        }
        
        return order
    }
    
    // MARK: 손님 대기 시간 설정
    private func setGuestWatingTime(_ type: GuestType, order: [Int]) -> Double {
        var multiple: Double = 0 // 손님 종류에 따른 대기 시간 설정을 위함
        var time: Double = 0
        
        switch type {
        case .relax:
            multiple = 2.0
            break
        case .normal:
            multiple = 1.7
            break
        case .impatient:
            multiple = 1.5
            break
        }
        
        order.enumerated().forEach { i, count in
            guard let skewer = self.skewerModel.read(at: i) else { return }
            
            time += Double(count * skewer.time)
        }
        
        return time * multiple
    }
    
    // MARK: 판매 이벤트 처리
    @IBAction func sell(_ sender: UIButton) {
        let at = sender.tag
        
        guard guestModel.count > at else { return }
        
        guard let guest = guestModel.read(at: at) else { return }
        
        var money = 0
        
        var i = 0
        for count in guest.order {
            guard let skewer = self.skewerModel.read(at: i) else { return }
            
            let skewerCount = getSkewerCount(skewer.type)
            
            if (skewerCount < count) {
                print("\(skewer.type.title) 개수가 부족합니다.")
                return
            } else {
                setSkewerCount(skewer.type, count: -count)
                money += count * skewer.price
            }
            i += 1
        }
        
        let data = Guest(type: guest.type, state: .leave, time: guest.time, order: guest.order)
        
        if self.guestModel.update(at: at, data) {
            print("\(money)원의 수익이 발생하였습니다 !!!")
            print("총 금액 ::: \(self.sales)")
            self.sales += money
            self.salesLabel.text = "매출액: \(self.sales)원"
            self.setGuestView(at: at)
        }
        
        return
    }
    
    // MARK: 불판에 꼬치 올리기 / 가져오기
    @IBAction func setGrill(_ sender: UIButton) {
        let at = sender.tag
        let selectedSkewer = skewerSegmentControl.selectedSegmentIndex
        
        if let grill = grillModel.read(at: at), grill.state != .empty {
            if grill.state != .raw {
                // 익은 경우 해당 꼬치 개수 증가
                if grill.state == .roast {
                    setSkewerCount(grill.skewer!.type, count: 1)
                    print("\(grill.skewer!.type.title) 개수 1개 증가. 총 개수: \(getSkewerCount(grill.skewer!.type))")
                } else {
                    print("타버린 꼬치는 버려집니다 ㅠㅠ")
                }
                
                if grillModel.update(at: at, Grill(state: .empty, skewer: nil)) {
                    setGrillView(at: at, empty: true)
                }
            } else {
                print("아직 꼬치가 익지 않았습니다 !!!")
            }
        } else {
            createGrillThread(at: at, skewerAt: selectedSkewer)
        }
    }
    
    // MARK: 불판 UI 설정
    private func setGrillView(at: Int, empty: Bool = false) {
        guard grillModel.count > at else { return }
        
        guard let grill = self.grillModel.read(at: at) else { return }
        
        let skewerTitle = !empty ? grill.skewer!.type.title : "꼬치"
        let grillStateTitle = grill.state.title
        let btnTitle = !empty ? "가져오기" : "추가"
        
        switch at {
        case 0:
            firstGrillSkewerLabel.text = skewerTitle
            firstGrillStateLabel.text = grillStateTitle
            firstGrillBtn.setTitle(btnTitle, for: .normal)
            break
        case 1:
            secondGrillSkewerLabel.text = skewerTitle
            secondGrillStateLabel.text = grillStateTitle
            secondGrillBtn.setTitle(btnTitle, for: .normal)
            break
        case 2:
            thirdGrillSkewerLabel.text = skewerTitle
            thirdGrillStateLabel.text = grillStateTitle
            thirdGrillBtn.setTitle(btnTitle, for: .normal)
            break
        default:
            break
        }
    }
    
    // MARK: 손님 UI 설정
    // TODO: 손님의 주문 내역, 남은 대기 시간 보여져야 함
    private func setGuestView(at: Int) {
        guard guestModel.count > at else { return }
        
        guard let guest = self.guestModel.read(at: at) else { return }
        
        let typeTitle = guest.type.title
        let stateTitle = guest.state.title
        
        switch at {
        case 0:
            firstGuestTypeLabel.text = typeTitle
            firstGuestStateLabel.text = stateTitle
            break
        case 1:
            secondGuestTypeLabel.text = typeTitle
            secondGuestStateLabel.text = stateTitle
            break
        case 2:
            thirdGuestTypeLabel.text = typeTitle
            thirdGuestStateLabel.text = stateTitle
            break
        default:
            break
        }
    }
    
    // MARK: 꼬치 개수 설정
    private func setSkewerCount(_ type: SkewerType, count: Int) {
        switch type {
        case .ricecake:
            riceCakeSkewerCount += count
            riceCakeSkewerCountLabel.text = "떡꼬치: \(riceCakeSkewerCount)개"
        case .chicken:
            chickenSkewerCount += count
            chickenSkewerCountLabel.text = "닭꼬치: \(chickenSkewerCount)개"
        case .lamb:
            lambSkewerCount += count
            lambSkewerCountLabel.text = "양꼬치: \(lambSkewerCount)개"
        }
    }
    
    // MARK: 꼬치 개수 가져오기
    private func getSkewerCount(_ type: SkewerType) -> Int {
        switch type {
        case .ricecake:
            return riceCakeSkewerCount
        case .chicken:
            return chickenSkewerCount
        case .lamb:
            return lambSkewerCount
        }
    }
}
