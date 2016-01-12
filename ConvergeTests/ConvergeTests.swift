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

class ConvergeTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var importer: Importer!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        setUpCoreData()
        
        // FIXME
        importer = Importer(context: context)
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
    
    // MARK: -
    
    func seedFilePath(entityClass: AnyClass, dir seedDirectory: String) -> String {
        return NSBundle(forClass: self.dynamicType).pathForResource(NSStringFromClass(entityClass), ofType: "json", inDirectory: seedDirectory)!
    }
    
    // MARK: - Merging logic
    
    func testMergeAttributes() {
        let seedDirectory = "Seeds/testMergeAttributes"
        let importTestEntityOneExpectation = expectationWithDescription("import TestEntityOne")
        
        importer.importFrom(recordClass: TestEntityOne.self, filePath:seedFilePath(TestEntityOne.self, dir: seedDirectory), success: { (result) in
            importTestEntityOneExpectation.fulfill()
            
            XCTAssertEqual(try! TestEntityOne.allRecords(sortedBy: nil, context: self.context).count, 2)
            XCTAssertEqual(try! TestEntityOne.recordForID(1, context: self.context), "foo")
            XCTAssertEqual(try! TestEntityOne.recordForID(2, context: self.context), "bar")
            
        }, failure: { (error) in
            XCTFail("Error importing: \(error)")
        })
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testMergeForeignKeysToOne() {
        let seedDirectory = "Seeds/testMergeForeignKeysToOne"
        let importTestEntityOneExpectation = expectationWithDescription("import TestEntityOne")
        let importTestEntityTwoExpectation = expectationWithDescription("import TestEntityTwo")
        
        importer.importFrom(recordClass: TestEntityOne.self, filePath: seedFilePath(TestEntityOne.self, dir: seedDirectory), success: { (result) -> Void in
            
            importTestEntityOneExpectation.fulfill()
            
            self.importer.importFrom(recordClass: TestEntityTwo.self, filePath: self.seedFilePath(TestEntityTwo.self, dir: seedDirectory), success: { (result) -> Void in
                
                importTestEntityTwoExpectation.fulfill()
                
                XCTAssertEqual(try! TestEntityOne.allRecords(sortedBy: nil, context: self.context).count, 2)
                XCTAssertEqual(try! TestEntityTwo.allRecords(sortedBy: nil, context: self.context).count, 2)
                
                XCTAssertEqual((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityTwos!.count, 1)
                XCTAssertEqual((try! TestEntityOne.recordForID(2, context: self.context) as! TestEntityOne).testEntityTwos!.count, 1)
                
                XCTAssertEqual((try! TestEntityTwo.recordForID(1, context: self.context) as! TestEntityTwo).testEntityOne?.someString, "foo")
                XCTAssertEqual((try! TestEntityTwo.recordForID(2, context: self.context) as! TestEntityTwo).testEntityOne?.someString, "bar")
                
            }, failure: { (error) -> Void in
                XCTFail("Error importing: \(error)")
            })
            
        }) { (error) -> Void in
            XCTFail("Error importing: \(error)")
        }
    }
    
    func testMergeForeignKeysToMany() {
        let seedDirectory = "Seeds/testMergeForeignKeysToMany"
        let importTestEntityOneExpectation = expectationWithDescription("import TestEntityOne")
        let importTestEntityThreeExpectation = expectationWithDescription("import TestEntityThree")
        
        importer.importFrom(recordClass: TestEntityOne.self, filePath: seedFilePath(TestEntityOne.self, dir: seedDirectory), success: { (result) -> Void in
            
            importTestEntityOneExpectation.fulfill()
            
            self.importer.importFrom(recordClass: TestEntityThree.self, filePath: self.seedFilePath(TestEntityThree.self, dir: seedDirectory), success: { (result) -> Void in
                
                importTestEntityThreeExpectation.fulfill()
                
                XCTAssertEqual(try! TestEntityOne.allRecords(sortedBy: nil, context: self.context).count, 2)
                XCTAssertEqual(try! TestEntityThree.allRecords(sortedBy: nil, context: self.context).count, 2)
                
                XCTAssertEqual((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityThrees!.count, 1)
                XCTAssertEqual((try! TestEntityOne.recordForID(2, context: self.context) as! TestEntityOne).testEntityThrees!.count, 1)
                
                XCTAssertEqual(((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityThrees![0] as! TestEntityThree).id, 1)
                XCTAssertEqual(((try! TestEntityOne.recordForID(2, context: self.context) as! TestEntityOne).testEntityThrees![1] as! TestEntityThree).id, 2)
                
            }, failure: { (error) -> Void in
                XCTFail("Error importing: \(error)")
            })
            
        }) { (error) -> Void in
            XCTFail("Error importing: \(error)")
        }
    }
    
    func testMergeEmbeddedRecordsToOne() {
        let seedDirectory = "Seeds/testMergeEmbeddedRecordsToOne"
        let importTestEntityTwoExpectation = expectationWithDescription("import TestEntityTwo")
        
        importer.importFrom(recordClass: TestEntityTwo.self, filePath:seedFilePath(TestEntityTwo.self, dir: seedDirectory), success: { (result) in
            importTestEntityTwoExpectation.fulfill()
            
            XCTAssertEqual(try! TestEntityOne.allRecords(sortedBy: nil, context: self.context).count, 2)
            XCTAssertEqual(try! TestEntityTwo.allRecords(sortedBy: nil, context: self.context).count, 2)
            
            XCTAssertEqual((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityThrees!.count, 1)
            XCTAssertEqual((try! TestEntityOne.recordForID(2, context: self.context) as! TestEntityOne).testEntityThrees!.count, 1)
            
            XCTAssertEqual((try! TestEntityTwo.recordForID(1, context: self.context) as! TestEntityTwo).testEntityOne?.someString, "foo")
            XCTAssertEqual((try! TestEntityTwo.recordForID(2, context: self.context) as! TestEntityTwo).testEntityOne?.someString, "bar")
            
        }, failure: { (error) in
            XCTFail("Error importing: \(error)")
        })
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testMergeEmbeddedRecordsToMany() {
        let seedDirectory = "Seeds/testMergeEmbeddedRecordsToMany"
        let importTestEntityThreeExpectation = expectationWithDescription("import TestEntityThree")
        
        importer.importFrom(recordClass: TestEntityThree.self, filePath:seedFilePath(TestEntityThree.self, dir: seedDirectory), success: { (result) in
            importTestEntityThreeExpectation.fulfill()
            
            XCTAssertEqual(try! TestEntityOne.allRecords(sortedBy: nil, context: self.context).count, 3)
            XCTAssertEqual(try! TestEntityThree.allRecords(sortedBy: nil, context: self.context).count, 2)
            
            XCTAssertEqual((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityThrees!.count, 1)
            
            XCTAssertEqual(((try! TestEntityOne.recordForID(1, context: self.context) as! TestEntityOne).testEntityThrees![0] as! TestEntityThree).id, 1)
            XCTAssertEqual(((try! TestEntityOne.recordForID(2, context: self.context) as! TestEntityOne).testEntityThrees![0] as! TestEntityThree).id, 2)
            XCTAssertEqual(((try! TestEntityOne.recordForID(3, context: self.context) as! TestEntityOne).testEntityThrees![0] as! TestEntityThree).id, 3)
            
        }, failure: { (error) in
            XCTFail("Error importing: \(error)")
        })
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    // MARK: - Conversions
    
    func testStringToDecimalConversion() {
        let seedDirectory = "Seeds/testStringToDecimalConversion"
        let importTestEntityTwoExpectation = expectationWithDescription("import TestEntityTwo")
        
        importer.importFrom(recordClass: TestEntityTwo.self, filePath:seedFilePath(TestEntityTwo.self, dir: seedDirectory), success: { (result) in
            importTestEntityTwoExpectation.fulfill()
            
            XCTAssertEqual((try! TestEntityTwo.recordForID(1, context: self.context) as! TestEntityTwo).someDecimal, NSDecimalNumber(string: "3.14159"))
            XCTAssertEqual((try! TestEntityTwo.recordForID(2, context: self.context) as! TestEntityTwo).someDecimal, NSDecimalNumber(string: "0.3"))
            
        }, failure: { (error) in
            XCTFail("Error importing: \(error)")
        })
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
}
