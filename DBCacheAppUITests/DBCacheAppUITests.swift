//
//  DBCacheAppUITests.swift
//  DBCacheAppUITests
//
//  Created by Denis Sheikherev on 27.05.2021.
//

import XCTest

class DBCacheAppUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testCacheControlsAreDisabledOnLaunch() {
        XCTAssertTrue(app.buttons["+"].isEnabled == false)
        XCTAssertTrue(app.buttons["-"].isEnabled == false)
        XCTAssertTrue(app.buttons["a"].isEnabled == false)
        XCTAssertTrue(app.buttons["Apply"].isEnabled == false)
    }
    
    func testAllViewsExist() {
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        
        let addNodeButton = app.buttons["+"]
        let removeNodeButton = app.buttons["-"]
        let alterNodeButton = app.buttons["a"]
        let applyChangesButton = app.buttons["Apply"]
        let resetButton = app.buttons["Reset"]
        let copyToCacheButton = app.buttons["<<<"]
        
        XCTAssertTrue(cacheTableView.element.exists)
        XCTAssertTrue(dbTableView.element.exists)
        
        XCTAssertTrue(addNodeButton.exists)
        XCTAssertTrue(removeNodeButton.exists)
        XCTAssertTrue(alterNodeButton.exists)
        XCTAssertTrue(applyChangesButton.exists)
        XCTAssertTrue(resetButton.exists)
        XCTAssertTrue(copyToCacheButton.exists)
    }
    
    func testCopyEntryToCache() {
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let rootEntryCell = dbTableView.cells.staticTexts["Node0"]
        XCTAssertTrue(rootEntryCell.exists)
        
        rootEntryCell.tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        let cacheEntryCell = cacheTableView.cells.staticTexts["Node0"]
        XCTAssertTrue(cacheEntryCell.exists)
    }
    
    func testAddChildEntry() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["+"].isEnabled == true)

        app.buttons["+"].tap()
        XCTAssertTrue(app.otherElements.alerts["Add new entry"].exists)
        
        app.textFields.firstMatch.typeText("NewNode")
        app.buttons["Add"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["NewNode"].exists)
        
        app.buttons["Apply"].tap()
        XCTAssertTrue(dbTableView.cells.staticTexts["NewNode"].waitForExistence(timeout: 5))
    }
    
    func testAddEntryWithEmptyValue() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["+"].isEnabled == true)
        
        app.buttons["+"].tap()
        XCTAssertTrue(app.otherElements.alerts["Add new entry"].exists)
        
        app.buttons["Add"].tap()
        XCTAssertEqual(cacheTableView.cells.count, 1)
    }
    
    func testDestroyNewlyAddedCacheEntry() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["+"].isEnabled == true)
        
        app.buttons["+"].tap()
        XCTAssertTrue(app.otherElements.alerts["Add new entry"].exists)
        
        app.textFields.firstMatch.typeText("NewNode")
        app.buttons["Add"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["NewNode"].exists)
        XCTAssertEqual(cacheTableView.cells.count, 2)
        
        cacheTableView.cells.staticTexts["NewNode"].tap()
        app.buttons["-"].tap()
        XCTAssertEqual(cacheTableView.cells.count, 1)
    }
    
    func testControlsDisabledForRemovedCacheEntry() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["-"].isEnabled == true)
        
        app.buttons["-"].tap()
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["+"].isEnabled == false)
        XCTAssertTrue(app.buttons["-"].isEnabled == false)
        XCTAssertTrue(app.buttons["a"].isEnabled == false)
    }
    
    func testCopyToCacheDisabledForRemovedDbEntry() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["-"].isEnabled == true)
        
        app.buttons["-"].tap()
        app.buttons["Apply"].tap()
        XCTAssertTrue(dbTableView.cells.staticTexts["Node1"].waitForExistence(timeout: 5))
        
        dbTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        dbTableView.cells.staticTexts["Node2"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        dbTableView.cells.staticTexts["Node3"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        dbTableView.cells.staticTexts["Node4"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        dbTableView.cells.staticTexts["Node5"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
    }
    
    func testInitialStateOnReset() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["-"].isEnabled == true)
        
        app.buttons["-"].tap()
        app.buttons["Apply"].tap()
        XCTAssertTrue(dbTableView.cells.staticTexts["Node1"].waitForExistence(timeout: 5))
        
        dbTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["<<<"].isEnabled == false)
        
        app.buttons["Reset"].tap()
        XCTAssertTrue(dbTableView.cells.staticTexts["Node0"].waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.buttons["+"].isEnabled == false)
        XCTAssertTrue(app.buttons["-"].isEnabled == false)
        XCTAssertTrue(app.buttons["a"].isEnabled == false)
        XCTAssertTrue(app.buttons["Apply"].isEnabled == false)
        XCTAssertEqual(cacheTableView.cells.count, 0)
    }
    
    func testCantChangeEntryWithEmptyValue() {
        let dbTableView = app.tables.matching(identifier: "dbTableViewIdentifier")
        let cacheTableView = app.tables.matching(identifier: "cacheTableViewIdentifier")
        
        dbTableView.cells.staticTexts["Node1"].tap()
        
        XCTAssertTrue(app.buttons["<<<"].isEnabled == true)
        app.buttons["<<<"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        
        cacheTableView.cells.staticTexts["Node1"].tap()
        XCTAssertTrue(app.buttons["a"].isEnabled == true)
        
        app.buttons["a"].tap()
        XCTAssertTrue(app.otherElements.alerts["Change entry"].exists)
        
        app.buttons["Change"].tap()
        XCTAssertTrue(cacheTableView.cells.staticTexts["Node1"].exists)
        XCTAssertEqual(cacheTableView.cells.count, 1)
    }
}
