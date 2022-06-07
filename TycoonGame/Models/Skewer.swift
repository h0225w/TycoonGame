//
//  Skewers.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 꼬치 종류 (떡꼬치, 닭꼬치, 양꼬치)
enum SkewerType {
    case ricecake, chicken, lamb
}

// MARK: - Entity
struct Skewer {
    let type: SkewerType // 종류
    let time: Int // 굽는 시간
    let price: Int // 가격
    let count: Int // 현재 개수
}

// MARK: - Model
class SkewerModel {
    private var storage: [Skewer] = []
    
    public var count: Int { storage.count }
    
    // MARK: - Nodel > Create
    public func create(_ data: Skewer) {
        self.storage.append(data)
    }
    
    // MARK: - Model > Read
    public func read(at: Int) -> Skewer? {
        guard count > at else { return nil }
        
        return storage[at]
    }
    
    // MARK: - Model > Update
    public func update(at: Int, _ data: Skewer) -> Bool{
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
