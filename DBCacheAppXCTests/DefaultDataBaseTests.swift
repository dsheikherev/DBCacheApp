//
//  DefaultDataBaseTests.swift
//
//
//  Created by Denis Sheikherev on 27.05.2021.
//

import XCTest

@testable import DBCacheApp

class DefaultDataBaseTests: XCTestCase {

    var database: Database!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        database = DefaultDatabase()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        database = nil
        try super.tearDownWithError()
    }

    func testNilOnGetEntryWithUnknownId() {
        // Check that DefaultDatabase returns nil
        // then it doesn't have entry with such Id
        let count = database.getAllEntries().count
        let nonExistentID: UInt64 = 10000000
        XCTAssertTrue(nonExistentID > count)
        
        let entry = database.getEntry(with: nonExistentID)
        XCTAssertNil(entry)
    }
    
    func testCountOnNewEntryAdded() {
        let countBefore = database.getAllEntries().count
        let id = DefaultDatabase.UniqueId.generate()
        database.addEntry(id: id, value: "NewNode", parentId: 0, isRemoved: false)
        let countAfter = database.getAllEntries().count
        
        XCTAssertEqual(countBefore, countAfter - 1)
    }
    
    func testValueAddedOnAddEntry() {
        let id = DefaultDatabase.UniqueId.generate()
        let valueBefore = "NewNode"
        database.addEntry(id: id, value: valueBefore, parentId: 0, isRemoved: false)
        let valueAfter = database.getEntry(with: id)?.value
        
        XCTAssert(valueAfter != nil)
        XCTAssertEqual(valueBefore, valueAfter)
    }
    
    func testAllEntriesRemovedOnRemoveAll() {
        database.removeAllEntries()
        XCTAssertTrue(!database.getAllEntries().contains { $0.isRemoved == false })
    }
    
    func testEntriesRemovedAfterRootRemoved() {
        XCTAssertTrue(!database.getAllEntries().contains { $0.isRemoved == true })
        // we know that Root's Id is 0
        // let's remove it
        database.removeEntry(id: 0)
        XCTAssertTrue(!database.getAllEntries().contains { $0.isRemoved == false })
    }
    
    func testValueChangedOnChangeEntry() {
        let newValue = "NEWNODE"
        
        // remember Root's value before changing
        let valueBefore = database.getEntry(with: 0)?.value
        XCTAssert(valueBefore != nil)
        
        database.changeEntry(id: 0, value: newValue, isRemoved: false)
        let valueAfter = database.getEntry(with: 0)?.value
        XCTAssert(valueAfter != nil)
        
        XCTAssertTrue(valueBefore != valueAfter)
        XCTAssertEqual(valueAfter, newValue)
    }
    
    func testEmptyValueOnNewEntryAdded() {
        let countBefore = database.getAllEntries().count
        let id = DefaultDatabase.UniqueId.generate()
        database.addEntry(id: id, value: "", parentId: 0, isRemoved: false)
        let countAfter = database.getAllEntries().count
        
        XCTAssertEqual(countBefore, countAfter)
    }
    
    func testEmptyValueOnEntryChanged() {
        let emptyValue = ""
        
        // remember Root's value before changing
        let valueBefore = database.getEntry(with: 0)?.value
        XCTAssert(valueBefore != nil)
        
        database.changeEntry(id: 0, value: emptyValue, isRemoved: false)
        let valueAfter = database.getEntry(with: 0)?.value
        XCTAssert(valueAfter != nil)
    
        XCTAssertEqual(valueBefore, valueAfter)
        
        XCTAssertTrue(valueAfter != emptyValue)
    }
    
    func testCountOnReset() {
        let countBefore = database.getAllEntries().count
        
        for i in 0 ..< 2 {
            let id = DefaultDatabase.UniqueId.generate()
            database.addEntry(id: id, value: "NewNode\(i)", parentId: 0, isRemoved: false)
        }
        
        let countAfter = database.getAllEntries().count
        XCTAssertTrue(countBefore != countAfter)
        
        database.reset()
        
        let countAfterReset = database.getAllEntries().count
        XCTAssertEqual(countBefore, countAfterReset)
    }
    
    func testNewEntryOnAddedToRemovedParent() {
        let node1Id: UInt64 = 1
        var node1 = database.getEntry(with: node1Id)
        XCTAssertEqual(node1!.isRemoved, false)
        
        database.removeEntry(id: node1Id)
        node1 = database.getEntry(with: node1Id)
        
        let id = DefaultDatabase.UniqueId.generate()
        database.addEntry(id: id, value: "NewNodeToRemovedParent", parentId: node1Id, isRemoved: false)
        let removedChild = database.getEntry(with: id)
        
        // If we ask for removed entry
        // as a result we get nil.
        // So nil will mean isRemoved = true
        XCTAssertEqual(removedChild?.isRemoved ?? true, true)
    }
}
