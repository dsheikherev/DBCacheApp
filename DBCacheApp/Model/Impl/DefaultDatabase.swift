//
//  DefaultDatabase.swift
//  DBCacheApp
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

final class DefaultDatabase: Database {
    
    public enum UniqueId {
        private static var idSequence = sequence(first: UInt64(0), next: { $0 + 1 })
        
        public static func generate() -> UInt64 {
            return idSequence.next()!
        }
        
        public static func reset() {
            idSequence = sequence(first: UInt64(0), next: { $0 + 1 })
        }
    }
    
    private var dbEntries = [UInt64: DbEntry](minimumCapacity: 25)
    
    init() {
        UniqueId.reset()
        load()
    }
    
    func getEntry(with id: UInt64) -> Entry? {
        guard let entry = dbEntries[id] else { return nil }
//        guard !entry.isRemoved else { return nil }
        
        return entry
    }
    
    func getAllEntries() -> [Entry] {
        // I think ideally Database shouldn't return removed entries
        // But it our case we should show them on TableView
//        return Array(dbEntries.values.filter { !$0.isRemoved })
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
        guard !value.isEmpty else { return false }
        
        let isParentRemoved = dbEntries[parentId]?.isRemoved ?? false
        
        dbEntries[id] = DbEntry(id: id, value: value, parentId: parentId, isRemoved: isParentRemoved ? true : isRemoved)
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
    
    @discardableResult
    func removeEntry(id: UInt64) -> Bool {
        guard let entry = dbEntries[id] else { return false }
        
        dbEntries[id] = DbEntry(id: entry.id, value: entry.value, parentId: entry.parentId, isRemoved: true)
        
        let childrenIds = dbEntries.filter { $0.value.parentId == id}
                                   .map { $0.value.id }
        
        for childId in childrenIds {
            removeEntry(id: childId)
        }
        return true
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
        dbEntries[id] = DbEntry(id: id, value: "Node5", parentId: 4)
        
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node6", parentId: 1)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node7", parentId: 6)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node8", parentId: 7)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node9", parentId: 8)

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node10", parentId: 0)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node11", parentId: 10)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node12", parentId: 11)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node13", parentId: 12)
        
        
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node14", parentId: 0)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node15", parentId: 14)
        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node16", parentId: 15)

        id = UniqueId.generate()
        dbEntries[id] = DbEntry(id: id, value: "Node17", parentId: 0)
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
