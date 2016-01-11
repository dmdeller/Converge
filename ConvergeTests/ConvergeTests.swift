//
//  ConvergeTests.swift
//  ConvergeTests
//
//  Created by David (work) on 1/11/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import XCTest
import CoreData
@testable import Converge

class TestEntityOne: NSManagedObject {
    
}

class ConvergeTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var importer: Importer!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        setUpCoreData()
        
        // FIXME
        importer = Importer(context_: context)
    }
    
    func setUpCoreData() {
        let modelURL = NSBundle(forClass: self.dynamicType).URLForResource("TestModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch {
            fatalError("Failed to init persistent store coordinator")
        }
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        context = nil
        importer = nil
        
        super.tearDown()
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    // MARK: - Merging logic
    
    func testMergeAttributes() {
        let seedDirectory = "Seeds/testMergeAttributes"
        let importTestEntityOneExpectation = expectationWithDescription("import TestEntityOne")
        
        importer.importFrom(TestEntityOne.self, filePath:NSBundle(forClass: self.dynamicType).pathForResource("TestEntityOne", ofType: "json", inDirectory: seedDirectory)!, success: { (result) in
            importTestEntityOneExpectation.fulfill()
            
            // TODO: More assertions
            
        }, failure: { (error) in
            XCTFail("Error importing: \(error)")
        })
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
}
