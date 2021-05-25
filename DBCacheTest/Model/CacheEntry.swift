//
//  CacheEntry.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

struct CacheEntry: Entry {
    var value: String
    var id: UInt64
    var parentId: UInt64?
    var isRemoved: Bool = false
}
