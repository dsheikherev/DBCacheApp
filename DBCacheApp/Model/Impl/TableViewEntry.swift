//
//  TableViewEntry.swift
//  DBCacheApp
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

struct TableViewEntry: Entry {
    var value: String
    var id: UInt64
    var parentId: UInt64?
    var isRemoved: Bool
    var indentation: Int
}

extension TableViewEntry {
    init(from entry: Entry, indentation: Int) {
        self.value = entry.value
        self.id = entry.id
        self.parentId = entry.parentId
        self.isRemoved = entry.isRemoved
        self.indentation = indentation
    }
}
