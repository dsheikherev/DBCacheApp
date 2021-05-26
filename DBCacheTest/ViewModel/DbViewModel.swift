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
    var dbEntries: Observable<[TableViewEntry]> { get }
    var cacheEntries: Observable<[TableViewEntry]> { get }
    var isCacheChangesAllowed: Observable<Bool> { get }
    var isCopyToCacheAllowed: Observable<Bool> { get }
    var isApplyChangesAllowed: Observable<Bool> { get }
}

protocol DbViewModel: DbViewModelInput & DbViewModelOutput {}

final class DefaultDbViewModel: DbViewModel {
    
    private (set) var dbEntries: Observable<[TableViewEntry]> = Observable([])
    private (set) var cacheEntries: Observable<[TableViewEntry]> = Observable([])
    
    private (set) var isCacheChangesAllowed: Observable<Bool> = Observable(false)
    private (set) var isCopyToCacheAllowed: Observable<Bool> = Observable(false)
    private (set) var isApplyChangesAllowed: Observable<Bool> = Observable(false)
    
    //TODO: MAKE PROTOCOL TO COMMUNICATE
    let dataBase = Database()
    
    func onViewDidLoad() {
//        dataBase.load()
        load()
    }
    
    func onCacheEntrySelected(index: Int) {
        isCacheChangesAllowed.value = !cacheEntries.value[index].isRemoved
    }
    
    func onDbEntrySelected(index: Int) {
        isCopyToCacheAllowed.value = !dbEntries.value[index].isRemoved
    }
    
    func onCopyEntry(with index: Int) {
        isCopyToCacheAllowed.value = false
        isCacheChangesAllowed.value = false
        
        let entry = dbEntries.value[index]
        
        guard !entry.isRemoved else { return }
        guard !cacheEntries.value.contains(where: { $0.id == entry.id }) else { return }
        
        dataBase.copyToCache(id: entry.id)
        
        cacheEntries.value = makeTable(of: .Cache)
        
        isApplyChangesAllowed.value = !cacheEntries.value.isEmpty
    }
    
    func onAddNewEntry(with value: String, after: Int) {
        let parentId = cacheEntries.value[after].id
        dataBase.addToCache(value: value, parentId: parentId)
        
        cacheEntries.value = makeTable(of: .Cache)
        isCacheChangesAllowed.value = false
    }
    
    func onRemoveEntry(_ index: Int) {
        if cacheEntries.value[index].parentId == nil {
            dataBase.removeAll(within: Entries.Cache)
        } else {
            let id = cacheEntries.value[index].id
            dataBase.removeCache(with: id)
        }
        
        cacheEntries.value = makeTable(of: .Cache)
        isCacheChangesAllowed.value = false
    }
    
    func onChangeCacheEntry(_ index: Int, value: String) {
        let id = cacheEntries.value[index].id
        dataBase.changeCacheEntry(with: id, value: value)
        
        cacheEntries.value = makeTable(of: .Cache)
        isCacheChangesAllowed.value = false
    }
    
    func onApplyChanges() {
        
    }
    
    func onReset() {
        dataBase.reset()
        
        dbEntries.value.removeAll()
        cacheEntries.value.removeAll()
        
        load()
    }
    
    private func load() {
        dbEntries.value = makeTable(of: .Database)
    }
    
    private func makeTable(of entries: Entries) -> [TableViewEntry] {
        var tableEntries: [TableViewEntry] = []
        
        let collection = dataBase.getCollection(of: entries)
        
        for entry in collection {
            // Count indents for every entry to show hierarchy
            let indentation = dataBase.countParents(of: entry, in: collection)
            tableEntries.append(TableViewEntry(from: entry, indentation: indentation))
        }
        return tableEntries
    }
    
}
