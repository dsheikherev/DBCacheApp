//
//  Database.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 26.05.2021.
//

import Foundation

protocol Database {
    func getEntry(with id: UInt64) -> Entry?
    func getAll() -> [Entry]
    func removeAll()
    func add()
    
    func reset()
}
