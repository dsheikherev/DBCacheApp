//
//  DbViewModel.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

protocol DbViewModelInput {
    func onViewDidLoad()
    
    func onCopyEntry(with index: Int)
    func onAddNewNodeToCache()
    func onRemoveNodeFromCache()
    func onChangeValueOfNodeInCache()
    func onApplyChanges()
    func onReset()
}

protocol DbViewModelOutput {
    var database: Observable<[TableViewEntry]> { get }
    var cache: Observable<[TableViewEntry]> { get }
}

protocol DbViewModel: DbViewModelInput & DbViewModelOutput {}

final class DefaultDbViewModel: DbViewModel {
    
    var database: Observable<[TableViewEntry]> = Observable([])
    var cache: Observable<[TableViewEntry]> = Observable([])
    
    let db = Database()
    
    func onViewDidLoad() {
        db.load()
        load()
    }
    
    func onCopyEntry(with index: Int) {
        let entry = database.value[index]
        
        guard !entry.isRemoved else { return }
        guard !cache.value.contains(where: { $0.id == entry.id }) else { return }
        
        addToCache(entry: entry)
    }
    
    func onAddNewNodeToCache() {
    }
    
    func onRemoveNodeFromCache() {
    }
    
    func onChangeValueOfNodeInCache() {
    }
    
    func onApplyChanges() {
    }
    
    func onReset() {
        db.reset()
        
        database.value.removeAll()
        cache.value.removeAll()
        
        load()
    }
    
    private func load() {
        database.value = makeTable(from: db.dbEntries)
    }
    
    // Count indents for every entry to show hierarchy
    private func makeTable(from collection: [Entry]) -> [TableViewEntry] {
        var tableEntries: [TableViewEntry] = []
        
        for entry in collection {
            let indentation = db.countParents(of: entry, in: collection)
            tableEntries.append(TableViewEntry(from: entry, indentation: indentation))
        }
        return tableEntries
    }

    // To make a good-looking hierarchy,
    // the entries should be grouped according to the next scheme:
    // Children follow their parent
    private func groupParentsWithChildren() -> [Entry] {
        var parents: [Entry] = []
        
        // Entry is a parent if:
        // It has nil parentId
        // or
        // Entry is a child whose parent is not in the array.
        for entry in db.cacheEntries {
            if entry.parentId == nil ||
                !db.cacheEntries.contains(where: { $0.id == entry.parentId }) {
                parents.append(entry)
            }
        }
        
        var groupedCache: [Entry] = []
        
        for parent in parents {
            groupedCache += groupChildren(with: parent)
        }
        
        return groupedCache
    }
    
    func groupChildren(with parent: Entry) -> [Entry] {
        var group: [Entry] = []
        group.append(parent)
        let children = db.cacheEntries.filter { $0.parentId == parent.id }
        
        for child in children {
            group += groupChildren(with: child)
        }
        
        return group
    }
    
    private func addToCache(entry: Entry) {
        db.cacheEntries.append(entry)
        db.cacheEntries.sort { $0.id < $1.id }
        
        let grouppedCache = groupParentsWithChildren()
        
        cache.value = makeTable(from: grouppedCache)
    }
}
