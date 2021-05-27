//
//  Database.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 26.05.2021.
//

import Foundation

protocol Database {
    func getEntry(with id: UInt64) -> Entry?
    func getAllEntries() -> [Entry]
    
    @discardableResult
    func removeEntry(id: UInt64) -> Bool
    func removeAllEntries()
    
    @discardableResult
    func addEntry(id: UInt64, value: String, parentId: UInt64?, isRemoved: Bool) -> Bool
    
    @discardableResult
    func changeEntry(id: UInt64, value: String, isRemoved: Bool) -> Bool
    
    func reset()
}
