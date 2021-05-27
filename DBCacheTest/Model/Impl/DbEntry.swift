//
//  DbEntry.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

struct DbEntry: Entry {
    var id: UInt64
    var value: String
    var parentId: UInt64?
    var isRemoved: Bool = false
}
