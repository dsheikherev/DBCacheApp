//
//  CacheEntry.swift
//  DBCacheApp
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

class CacheEntry: Entry {
    var value: String
    var id: UInt64
    var parentId: UInt64?
    var isRemoved: Bool
    var isNew: Bool
    
    init(value: String, id: UInt64, parentId: UInt64?, isRemoved: Bool = false, isNew: Bool = false) {
        self.value = value
        self.id = id
        self.parentId = parentId
        self.isRemoved = isRemoved
        self.isNew = isNew
    }
}

extension CacheEntry: Equatable {
    static func == (lhs: CacheEntry, rhs: CacheEntry) -> Bool {
        lhs.id == rhs.id
    }
}
