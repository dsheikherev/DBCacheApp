//
//  Database.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

class Database {
    var dbEntries = [Entry]()
    var cacheEntries = [Entry]()
    
    func load() {
        dbEntries.append(DbEntry(value: "Node0", id: UniqueId.generate()))
        
        dbEntries.append(DbEntry(value: "Node1", id: UniqueId.generate(), parentId: 0))
        dbEntries.append(DbEntry(value: "Node2", id: UniqueId.generate(), parentId: 1))
        dbEntries.append(DbEntry(value: "Node3", id: UniqueId.generate(), parentId: 2))
        dbEntries.append(DbEntry(value: "Node4", id: UniqueId.generate(), parentId: 3))
        
        dbEntries.append(DbEntry(value: "Node5", id: UniqueId.generate(), parentId: 0))
        dbEntries.append(DbEntry(value: "Node6", id: UniqueId.generate(), parentId: 5))
        dbEntries.append(DbEntry(value: "Node7", id: UniqueId.generate(), parentId: 6))
        dbEntries.append(DbEntry(value: "Node8", id: UniqueId.generate(), parentId: 7))
        
        dbEntries.append(DbEntry(value: "Node9", id: UniqueId.generate(), parentId: 0))
        dbEntries.append(DbEntry(value: "Node10", id: UniqueId.generate(), parentId: 9))
        dbEntries.append(DbEntry(value: "Node11", id: UniqueId.generate(), parentId: 9))
        
        dbEntries.append(DbEntry(value: "Node12", id: UniqueId.generate(), parentId: 0))
    }
    
    func reset() {
        UniqueId.reset()
        dbEntries.removeAll()
        cacheEntries.removeAll()
        load()
    }
    
//    func countParents<T: Entry>(of node: T) -> Int where T.Value == String {
    func countParents(of entry: Entry, in collection: [Entry]) -> Int {
        guard let parentId = entry.parentId else {
            return 0
        }
        
        guard let parentNode = collection.first(where: { $0.id == parentId }) else { return 0 }
        return 1 + countParents(of: parentNode, in: collection)
    }
    
    
}
