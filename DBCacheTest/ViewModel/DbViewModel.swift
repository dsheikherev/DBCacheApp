//
//  DbViewModel.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

protocol DbViewModelInput {
    func onViewDidLoad()
    
    func onCacheEntrySelected(index: Int)
    func onDbEntrySelected(index: Int)
    
    func onCopyEntry(with index: Int)
    func onAddNewEntry(with value: String, after: Int)
    func onRemoveEntry(_ index: Int)
    func onChangeCacheEntry(_ index: Int, value: String)
    func onApplyChanges()
    func onReset()
}

protocol DbViewModelOutput {
    var dbTableEntries: Observable<[TableViewEntry]> { get }
    var cacheTableEntries: Observable<[TableViewEntry]> { get }
    var isCacheChangesAllowed: Observable<Bool> { get }
    var isCopyToCacheAllowed: Observable<Bool> { get }
    var isApplyChangesAllowed: Observable<Bool> { get }
}

protocol DbViewModel: DbViewModelInput & DbViewModelOutput {}

final class DefaultDbViewModel: DbViewModel {
    
    private (set) var dbTableEntries: Observable<[TableViewEntry]> = Observable([])
    private (set) var cacheTableEntries: Observable<[TableViewEntry]> = Observable([])

    private (set) var isCacheChangesAllowed: Observable<Bool> = Observable(false)
    private (set) var isCopyToCacheAllowed: Observable<Bool> = Observable(false)
    private (set) var isApplyChangesAllowed: Observable<Bool> = Observable(false)

    private let dataBase: Database
    
    private var cache: [CacheEntry]
    private var rootIsRemoved: Bool = false
    
    init(database: Database) {
        self.dataBase = database
        self.cache = [CacheEntry]()
    }

    //MARK: DbViewModelInput methods
    func onViewDidLoad() {
        load()
    }
    
    func onCacheEntrySelected(index: Int) {
        // It is not allowed to make changes in cache
        // if selected entry is removed
        isCacheChangesAllowed.value = !cacheTableEntries.value[index].isRemoved
    }
    
    func onDbEntrySelected(index: Int) {
        // It is not allowed to copy entry into cache
        // if selected entry is removed
        isCopyToCacheAllowed.value = !dbTableEntries.value[index].isRemoved
    }
    
    func onCopyEntry(with index: Int) {
        isCopyToCacheAllowed.value = false
        isCacheChangesAllowed.value = false
        
        let entryId = dbTableEntries.value[index].id
        
        guard let entry = dataBase.getEntry(with: entryId) else { return }
        guard !entry.isRemoved else { return }
        guard !cacheTableEntries.value.contains(where: { $0.id == entry.id }) else { return }
        
        cacheAddNew(value: entry.value, id: entry.id, parentId: entry.parentId, isRemoved: entry.isRemoved)
        
        let grouped = groupParentsWithChildren(in: cache)
        cacheTableEntries.value = makeTable(of: grouped)
        
        isApplyChangesAllowed.value = !cacheTableEntries.value.isEmpty
    }
    
    func onAddNewEntry(with value: String, after: Int) {
        guard !value.isEmpty else { return }
        
        let parentId = cacheTableEntries.value[after].id
        
        cacheAddNew(value: value, parentId: parentId, isNew: true)
        
        let grouped = groupParentsWithChildren(in: cache)
        cacheTableEntries.value = makeTable(of: grouped)
        
        isCacheChangesAllowed.value = false
    }
    
    func onRemoveEntry(_ index: Int) {
        // If we remove ROOT in cache then
        // all future added entries must be removed
        if cacheTableEntries.value[index].parentId == nil {
            rootIsRemoved = true
            cacheRemoveAll()
        } else {
            let id = cacheTableEntries.value[index].id
            cacheRemoveEntry(id: id)
        }
        
        let grouped = groupParentsWithChildren(in: cache)
        cacheTableEntries.value = makeTable(of: grouped)
        
        isCacheChangesAllowed.value = false
    }
    
    func onChangeCacheEntry(_ index: Int, value: String) {
        guard !value.isEmpty else { return }
        
        let id = cacheTableEntries.value[index].id
        cacheChangeEntry(id: id, value: value)
        
        let grouped = groupParentsWithChildren(in: cache)
        cacheTableEntries.value = makeTable(of: grouped)
        
        isCacheChangesAllowed.value = false
    }
    
    func onApplyChanges() {
        // If ROOT is removed in cache then
        // just remove all entries in DB
        if rootIsRemoved {
            dataBase.removeAllEntries()
        } else {
            for entry in cache {
                if entry.isNew {
                    // When we add new entry which is non-existent in database
                    // It can not be removed
                    // Because we destroy all new & removed entries
                    dataBase.addEntry(id: entry.id, value: entry.value, parentId: entry.parentId, isRemoved: false)
                } else {
                    dataBase.changeEntry(id: entry.id, value: entry.value, isRemoved: entry.isRemoved)
                }
            }
        }
        
        cache.removeAll()
        rootIsRemoved = false
        cacheTableEntries.value.removeAll()
        isCacheChangesAllowed.value = false
        isApplyChangesAllowed.value = false
        
        load()
    }
    
    func onReset() {
        dataBase.reset()
        
        cache.removeAll()
        rootIsRemoved = false
        
        dbTableEntries.value.removeAll()
        cacheTableEntries.value.removeAll()
        
        load()
    }
    
    //MARK: Private DefaultDbViewModel methods to work with cache
    private func cacheAddNew(value: String, id: UInt64 = UniqueId.generate(), parentId: UInt64?, isRemoved: Bool = false, isNew: Bool = false) {
        var shouldBeRemoved: Bool = isRemoved
        
        // if ROOT is removed in cache then
        // newly added entry should be removed too
        if rootIsRemoved {
            shouldBeRemoved = true
        } else {
            // Check that the parent of newly added entry is not removed in cache
            // If removed, then we must also be removed and remember to remove our children later
            if let parent = cache.first(where: {$0.id == parentId}), parent.isRemoved  {
                shouldBeRemoved = true
            }
        }
        
        let entry = CacheEntry(value: value, id: id, parentId: parentId, isRemoved: shouldBeRemoved, isNew: isNew)
        cache.append(entry)
        
        if shouldBeRemoved {
            cacheRemoveEntry(id: id)
        }
        
        cache.sort { $0.id < $1.id }
    }
    
    private func cacheRemoveAll() {
        // Entries that have been just created in cache
        // Just should be totally removed from cache array
        cache.removeAll(where: { $0.isNew })
        
        cache.forEach { $0.isRemoved = true }
    }
    
    private func cacheRemoveEntry(id: UInt64) {
        guard let entry = cache.first(where: { $0.id == id }) else { return }
        
        // If we remove the entry that has been just created in cache
        // Then we totally remove it (and its children) from cache array
        if entry.isNew {
            cacheDestroy(entry: entry)
            return
        }
        
        entry.isRemoved = true
        
        let children = cache.filter { $0.parentId == id }
        for child in children {
            cacheRemoveEntry(id: child.id)
        }
    }
    
    private func cacheDestroy(entry: CacheEntry) {
        
        let children = cache.filter { $0.parentId == entry.id }
        
        for child in children {
            cacheDestroy(entry: child)
        }
        
        if let index = cache.firstIndex(of: entry) {
            cache.remove(at: index)
        }
    }
    
    private func cacheChangeEntry(id: UInt64, value: String) {
        cache.first(where: { $0.id == id })?.value = value
    }
    
    //MARK: Private DefaultDbViewModel methods mostly for presenting data in View
    private func load() {
        var entries = dataBase.getAllEntries()
        entries = groupParentsWithChildren(in: entries)
        
        dbTableEntries.value = makeTable(of: entries)
    }
    
    private func makeTable(of entries: [Entry]) -> [TableViewEntry] {
        var tableEntries: [TableViewEntry] = []
        
        for entry in entries {
            // Count indents for every entry to show hierarchy
            let indentation = countParents(of: entry, in: entries)
            tableEntries.append(TableViewEntry(from: entry, indentation: indentation))
        }
        return tableEntries
    }
    
    private func countParents(of entry: Entry, in collection: [Entry]) -> Int {
        guard let parentId = entry.parentId else {
            return 0
        }

        guard let parentNode = collection.first(where: { $0.id == parentId }) else { return 0 }
        return 1 + countParents(of: parentNode, in: collection)
    }
    
    // To make a good-looking hierarchy,
    // the entries should be grouped according to the next scheme:
    // Children follow their parent
    private func groupParentsWithChildren(in collection: [Entry]) -> [Entry] {
        var parents: [Entry] = []
        
        // Entry is a parent if:
        // It has nil parentId
        // or
        // Entry is a child whose parent is not in the array.
        for entry in collection {
            if entry.parentId == nil ||
                !collection.contains(where: { $0.id == entry.parentId }) {
                parents.append(entry)
            }
        }
        
        var groupedCache: [Entry] = []
        
        for parent in parents {
            groupedCache += groupChildren(with: parent, in: collection)
        }
        
        return groupedCache
    }
    
    private func groupChildren(with parent: Entry, in collection: [Entry]) -> [Entry] {
        var group: [Entry] = []
        group.append(parent)
        let children = collection.filter { $0.parentId == parent.id }
        
        for child in children {
            group += groupChildren(with: child, in: collection)
        }
        
        return group
    }
}
