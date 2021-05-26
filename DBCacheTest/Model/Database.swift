//
//  Database.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

public enum Entries {
    case Database
    case Cache
}

class Database {
    var dbEntries = [Entry]()
    var cacheEntries = [CacheEntry]()
    
    init() {
        load()
    }
    
    private func load() {
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
    
    func getCollection(of type: Entries) -> [Entry] {
        let collection: [Entry]
        
        switch type {
            case .Database:
                collection = dbEntries
            case .Cache:
                collection = cacheEntries
        }
        
        return collection
    }
    
//    func countParents<T: Entry>(of node: T) -> Int where T.Value == String {
    func countParents(of entry: Entry, in collection: [Entry]) -> Int {
        guard let parentId = entry.parentId else {
            return 0
        }
        
        guard let parentNode = collection.first(where: { $0.id == parentId }) else { return 0 }
        return 1 + countParents(of: parentNode, in: collection)
    }
    
    func addToCache(value: String, parentId: UInt64) {
        let entry = CacheEntry(value: value, id: UniqueId.generate(), parentId: parentId, isRemoved: false)
        cacheEntries.append(entry)
        cacheEntries.sort { $0.id < $1.id }
        
        cacheEntries = groupParentsWithChildren()
    }
    
    func copyToCache(id: UInt64) {
        guard let dbEntry = dbEntries.first(where: { $0.id == id }) else { return }
        
        let newEntry = CacheEntry(value: dbEntry.value, id: dbEntry.id, parentId: dbEntry.parentId, isRemoved: dbEntry.isRemoved)
        
        cacheEntries.append(newEntry)
        cacheEntries.sort { $0.id < $1.id }
        
        cacheEntries = groupParentsWithChildren()
    }
    
    func changeCacheEntry(with id: UInt64, value: String) {
        for i in 0 ..< cacheEntries.count {
            if cacheEntries[i].id == id {
                cacheEntries[i].value = value
                return
            }
        }
    }
    
    func removeAll(within: Entries) {
        var collection: [Entry]
        
        switch within {
            case .Database:
                collection = dbEntries
            case .Cache:
                collection = cacheEntries
        }
        
        for i in 0 ..< collection.count {
            collection[i].isRemoved = true
        }
    }
    
    func removeCache(with id: UInt64) {
        
    }
    
    // To make a good-looking hierarchy,
    // the entries should be grouped according to the next scheme:
    // Children follow their parent
    func groupParentsWithChildren() -> [CacheEntry] {
        var parents: [CacheEntry] = []
        
        // Entry is a parent if:
        // It has nil parentId
        // or
        // Entry is a child whose parent is not in the array.
        for entry in cacheEntries {
            if entry.parentId == nil ||
                !cacheEntries.contains(where: { $0.id == entry.parentId }) {
                parents.append(entry)
            }
        }
        
        var groupedCache: [CacheEntry] = []
        
        for parent in parents {
            groupedCache += groupChildren(with: parent)
        }
        
        return groupedCache
    }
    
    func groupChildren(with parent: CacheEntry) -> [CacheEntry] {
        var group: [CacheEntry] = []
        group.append(parent)
        let children = cacheEntries.filter { $0.parentId == parent.id }
        
        for child in children {
            group += groupChildren(with: child)
        }
        
        return group
    }
    
//    func findRootEntry() -> Entry? {
//        dbEntries.first { $0.parentId == nil }
//    }
//    
//    func findChildren(of root: Entry) -> [UInt64] {
//        var ids = [UInt64]()
//        for dbEntry in dbEntries {
//            if dbEntry.parentId == root.id {
//                ids.append(dbEntry.id)
//            }
//        }
//        return ids
//    }
    
}
