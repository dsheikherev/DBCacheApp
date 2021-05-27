//
//  DefaultDatabase.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

final class DefaultDatabase: Database {
    private var dbEntries = [UInt64: DbEntry](minimumCapacity: 25)
    
    init() {
        load()
    }
    
    func getEntry(with id: UInt64) -> Entry? {
        guard let entry = dbEntries[id] else { return nil }
        return entry
    }
    
    func getAllEntries() -> [Entry] {
        return Array(dbEntries.values)
    }
    
    func removeAllEntries() {
        for (key, value) in dbEntries {
            dbEntries[key] = DbEntry(id: value.id, value: value.value, parentId: value.parentId, isRemoved: true)
        }
    }
    
    @discardableResult
    func addEntry(id: UInt64, value: String, parentId: UInt64?, isRemoved: Bool) -> Bool {
        // Default database does not allow to add one more ROOT entry
        guard let parentId = parentId else { return false }
        
        dbEntries[id] = DbEntry(id: id, value: value, parentId: parentId, isRemoved: isRemoved)
        return true
    }
    
    @discardableResult
    func changeEntry(id: UInt64, value: String, isRemoved: Bool) -> Bool {
        guard !value.isEmpty else { return false }
  
        if let entry = dbEntries[id] {
            dbEntries[id] = DbEntry(id: entry.id, value: value, parentId: entry.parentId, isRemoved: entry.isRemoved)
            if isRemoved {
                removeEntry(id: id)
            }
            return true
        }
        return false
    }
    
    func reset() {
        UniqueId.reset()
        dbEntries.removeAll()
        load()
    }
    
    private func removeEntry(id: UInt64) {
        guard let entry = dbEntries[id] else { return }
        
        dbEntries[id] = DbEntry(id: entry.id, value: entry.value, parentId: entry.parentId, isRemoved: true)
        
        let childrenIds = dbEntries.filter { $0.value.parentId == id}
                                   .map { $0.value.id }
        
        for childId in childrenIds {
            removeEntry(id: childId)
        }
    }
    
    private func load() {
        var id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node0")

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node1", parentId: 0)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node2", parentId: 1)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node3", parentId: 2)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node4", parentId: 3)

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node5", parentId: 0)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node6", parentId: 5)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node7", parentId: 6)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node8", parentId: 7)

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node9", parentId: 0)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node10", parentId: 9)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node11", parentId: 9)

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node12", parentId: 0)
    }

}






















//    func countParents<T: Entry>(of node: T) -> Int where T.Value == String {
//    func countParents(of entry: Entry, in collection: [Entry]) -> Int {
//        guard let parentId = entry.parentId else {
//            return 0
//        }
//
//        guard let parentNode = collection.first(where: { $0.id == parentId }) else { return 0 }
//        return 1 + countParents(of: parentNode, in: collection)
//    }
//
