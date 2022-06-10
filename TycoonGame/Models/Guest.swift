//
//  Guest.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 손님 종류 (여유로운 손님, 일반 손님, 급한 손님)
// CaseIterable: 배열 컬렉션과 같이 순회할 수 있게 해주는 프로토콜. 랜덤으로 손님 종류를 가져오기 위함
enum GuestType: CaseIterable {
    case relax, normal, impatient
}

// MARK: 손님 상태 (대기중, 떠남)
enum GuestState {
    case waiting, leave
}

// MARK: - Entity
struct Guest {
    let type: GuestType // 종류
    let state: GuestState // 상태
    let time: Double // 대기 시간
    let order: [Int] // 주문 (0: 떡꼬치, 1: 닭꼬치, 2: 양꼬치)
}

// MARK: - Model
class GuestModel {
    private var storage: [Guest] = []
    
    public var count: Int { storage.count }
    
    // MARK: - Model > Create
    public func create(_ data: Guest) {
        self.storage.append(data)
    }
    
    // MARK: - Model > Read
    public func read(at: Int) -> Guest? {
        guard count > at else { return nil }
        return storage[at]
    }
    
    // MARK: - Model > Update
    public func update(at: Int, _ data: Guest) -> Bool {
        guard count > at else { return false }
        self.storage[at] = data
        return true
    }
    
    // MARK: - Model > Delete
    public func delete(at: Int) -> Bool {
        guard count > at else { return false }
        self.storage.remove(at: at)
        return true
    }
}

