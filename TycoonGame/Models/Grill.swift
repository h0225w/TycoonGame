//
//  Grill.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 불판 상태 (안 익은, 익음, 탐)
enum Status {
    case raw, roast, burnt
}

// MARK: - Entity
struct Grill {
    let status: Status // 불판 상태
    let skewer: SkewerType // 불판에서 구워지고 있는 꼬치 종류
}

// MARK: - Model
class GrillModel {
    // C
    // R
    // U
    // D
}
