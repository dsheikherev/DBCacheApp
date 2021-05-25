//
//  Entry.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

protocol Entry {
//    associatedtype Value
//    var value: Value { get set }
    var value: String { get set }
    var id: UInt64 { get }
    var parentId: UInt64? { get }
    var isRemoved: Bool { get }
}
