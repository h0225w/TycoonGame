//
//  Skewers.swift
//  TycoonGame
//
//  Created by 박현우 on 2022/06/06.
//

import Foundation

// MARK: 꼬치 종류 (떡꼬치, 닭꼬치, 양꼬치)
enum SkewerType {
    case ricecakechicken, lamb
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
    // C
    // R
    // U
    // D
}
