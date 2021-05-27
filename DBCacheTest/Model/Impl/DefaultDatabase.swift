//
//  DefaultDatabase.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

final class DefaultDatabase: Database {
    private var dbEntries = [DbEntry]()
    
    init() {
        load()
    }
    
    func getEntry(with id: UInt64) -> Entry? {
        guard let entry = dbEntries.first(where: { $0.id == id }) else { return nil }
        return entry
    }
    
    func getAllEntries() -> [Entry] {
        return dbEntries
    }
    
    func removeAllEntries() {
        for i in 0 ..< dbEntries.count {
            dbEntries[i].isRemoved = true
        }
    }
    
    @discardableResult
    func addEntry(id: UInt64, value: String, parentId: UInt64?, isRemoved: Bool) -> Bool {
        // Default database does not allow to add one more ROOT entry
        guard let parentId = parentId else { return false }
        
        dbEntries.append(DbEntry(id: id, value: value, parentId: parentId, isRemoved: isRemoved))
        return true
    }
    
    @discardableResult
    func changeEntry(id: UInt64, value: String, isRemoved: Bool) -> Bool {
        guard !value.isEmpty else { return false }
        
        for i in 0 ..< dbEntries.count {
            if dbEntries[i].id == id {
                dbEntries[i].value = value
                if isRemoved {
                    removeEntry(id: id)
                }
                return true
            }
        }
        return false
    }
    
    func reset() {
        UniqueId.reset()
        dbEntries.removeAll()
        load()
    }
    
    private func removeEntry(id: UInt64) {
        for i in 0 ..< dbEntries.count {
            if dbEntries[i].id == id {
                dbEntries[i].isRemoved = true
                break
            }
        }
        
        let childrenIds = dbEntries.filter { $0.parentId == id }.map { $0.id }
        for childId in childrenIds {
            removeEntry(id: childId)
        }
    }
    
    private func load() {
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node0"))

        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node1", parentId: 0))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node2", parentId: 1))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node3", parentId: 2))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node4", parentId: 3))

        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node5", parentId: 0))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node6", parentId: 5))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node7", parentId: 6))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node8", parentId: 7))

        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node9", parentId: 0))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node10", parentId: 9))
        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node11", parentId: 9))

        dbEntries.append(DbEntry(id: UniqueId.generate(), value: "Node12", parentId: 0))
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
