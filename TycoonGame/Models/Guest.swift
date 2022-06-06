//
//  Guest.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 손님 종류 (여유로운 손님, 일반 손님, 급한 손님)
enum GuestType {
    case relax, normal, impatient
}

// MARK: - Entity
struct Guest {
    let type: GuestType // 종류
    let time: Int // 대기 시간
    let order: [Int] // 주문 (0: 떡꼬치, 1: 닭꼬치, 2: 양꼬치)
}

// MARK: - Model
class GuestModel {
    // C
    // R
    // U
    // D
}

