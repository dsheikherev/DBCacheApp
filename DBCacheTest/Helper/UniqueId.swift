//
//  UniqueId.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

enum UniqueId {
    private static var idSequence = sequence(first: UInt64(0), next: { $0 + 1 })
    
    static func generate() -> UInt64 {
        return idSequence.next()!
    }
    
    static func reset() {
        idSequence = sequence(first: UInt64(0), next: { $0 + 1 })
    }
}
