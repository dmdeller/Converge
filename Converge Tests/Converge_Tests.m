//
//  Converge_Tests.m
//  Converge Tests
//
//  Created by David Deller on 4/19/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>

#import "Converge.h"
#import "TestEntityOne.h"
#import "TestEntityTwo.h"
#import "TestEntityThree.h"
#import "TestEntityFour.h"

@interface Converge_Tests : XCTestCase

@property NSManagedObjectContext *context;
@property ConvergeImporter *importer;

@end

@implementation Converge_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self setUpCoreData];
    
    self.importer = [ConvergeImporter.alloc initWithContext:self.context];
}

- (void)setUpCoreData
{
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"TestModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil])
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to init persistent store coordinator" userInfo:nil];
    }
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.context setPersistentStoreCoordinator:coordinator];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.context = nil;
    self.importer = nil;
    
    [super tearDown];
}

#pragma mark - Merging logic

- (void)testMergeAttributes
{
    static NSString *seedDirectory = @"Seeds/testMergeAttributes";
    XCTestExpectation *importTestEntityOneExpectation = [self expectationWithDescription:@"import TestEntityOne"];
    
    [self.importer importFromRecordClass:TestEntityOne.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityOne" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityOneExpectation fulfill];
         
         XCTAssertEqual([TestEntityOne allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         XCTAssertEqualObjects([TestEntityOne recordForID:@1 context:self.context error:nil].someString, @"foo");
         XCTAssertEqualObjects([TestEntityOne recordForID:@2 context:self.context error:nil].someString, @"bar");
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testMergeForeignKeysToOne
{
    static NSString *seedDirectory = @"Seeds/testMergeForeignKeysToOne";
    XCTestExpectation *importTestEntityOneExpectation = [self expectationWithDescription:@"import TestEntityOne"];
    XCTestExpectation *importTestEntityTwoExpectation = [self expectationWithDescription:@"import TestEntityTwo"];
    
    [self.importer importFromRecordClass:TestEntityOne.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityOne" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityOneExpectation fulfill];
         
         [self.importer importFromRecordClass:TestEntityTwo.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityTwo" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
          {
              [importTestEntityTwoExpectation fulfill];
              
              XCTAssertEqual([TestEntityOne allRecordsSortedBy:nil context:self.context error:nil].count, 2);
              XCTAssertEqual([TestEntityTwo allRecordsSortedBy:nil context:self.context error:nil].count, 2);
              
              XCTAssertEqual([TestEntityOne recordForID:@1 context:self.context error:nil].testEntityTwos.count, 1);
              XCTAssertEqual([TestEntityOne recordForID:@2 context:self.context error:nil].testEntityTwos.count, 1);
              
              XCTAssertEqualObjects([TestEntityTwo recordForID:@1 context:self.context error:nil].testEntityOne.someString, @"foo");
              XCTAssertEqualObjects([TestEntityTwo recordForID:@2 context:self.context error:nil].testEntityOne.someString, @"bar");
          }
         failure:^(NSError *error)
          {
              XCTFail(@"Error importing: %@", error);
          }];
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testMergeForeignKeysToMany
{
    static NSString *seedDirectory = @"Seeds/testMergeForeignKeysToMany";
    XCTestExpectation *importTestEntityOneExpectation = [self expectationWithDescription:@"import TestEntityOne"];
    XCTestExpectation *importTestEntityThreeExpectation = [self expectationWithDescription:@"import TestEntityThree"];
    
    [self.importer importFromRecordClass:TestEntityOne.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityOne" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityOneExpectation fulfill];
         
         [self.importer importFromRecordClass:TestEntityThree.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityThree" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
          {
              [importTestEntityThreeExpectation fulfill];
              
              XCTAssertEqual([TestEntityOne allRecordsSortedBy:nil context:self.context error:nil].count, 2);
              XCTAssertEqual([TestEntityThree allRecordsSortedBy:nil context:self.context error:nil].count, 2);
              
              XCTAssertEqual([TestEntityOne recordForID:@1 context:self.context error:nil].testEntityThrees.count, 2);
              XCTAssertEqual([TestEntityOne recordForID:@2 context:self.context error:nil].testEntityThrees.count, 1);
              
              XCTAssertEqualObjects([[TestEntityOne recordForID:@1 context:self.context error:nil].testEntityThrees[0] id], @1);
              XCTAssertEqualObjects([[TestEntityOne recordForID:@1 context:self.context error:nil].testEntityThrees[1] id], @2);
          }
         failure:^(NSError *error)
          {
              XCTFail(@"Error importing: %@", error);
          }];
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testMergeEmbeddedRecordsToOne
{
    static NSString *seedDirectory = @"Seeds/testMergeEmbeddedRecordsToOne";
    XCTestExpectation *importTestEntityTwoExpectation = [self expectationWithDescription:@"import TestEntityTwo"];
    
    [self.importer importFromRecordClass:TestEntityTwo.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityTwo" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityTwoExpectation fulfill];
         
         XCTAssertEqual([TestEntityOne allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         XCTAssertEqual([TestEntityTwo allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         
         XCTAssertEqual([TestEntityOne recordForID:@1 context:self.context error:nil].testEntityTwos.count, 1);
         XCTAssertEqual([TestEntityOne recordForID:@2 context:self.context error:nil].testEntityTwos.count, 1);
         
         XCTAssertEqualObjects([TestEntityTwo recordForID:@1 context:self.context error:nil].testEntityOne.someString, @"foo");
         XCTAssertEqualObjects([TestEntityTwo recordForID:@2 context:self.context error:nil].testEntityOne.someString, @"bar");
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testMergeEmbeddedRecordsToMany
{
    static NSString *seedDirectory = @"Seeds/testMergeEmbeddedRecordsToMany";
    XCTestExpectation *importTestEntityThreeExpectation = [self expectationWithDescription:@"import TestEntityThree"];

    [self.importer importFromRecordClass:TestEntityThree.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityThree" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityThreeExpectation fulfill];
         
         XCTAssertEqual([TestEntityOne allRecordsSortedBy:nil context:self.context error:nil].count, 3);
         XCTAssertEqual([TestEntityThree allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         
         XCTAssertEqual([TestEntityOne recordForID:@1 context:self.context error:nil].testEntityThrees.count, 1);
         
         XCTAssertEqualObjects([[TestEntityOne recordForID:@1 context:self.context error:nil].testEntityThrees[0] id], @1);
         XCTAssertEqualObjects([[TestEntityOne recordForID:@2 context:self.context error:nil].testEntityThrees[0] id], @2);
         XCTAssertEqualObjects([[TestEntityOne recordForID:@3 context:self.context error:nil].testEntityThrees[0] id], @2);
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

#pragma mark - Conversions

- (void)testStringToDecimalConversion
{
    static NSString *seedDirectory = @"Seeds/testStringToDecimalConversion";
    XCTestExpectation *importTestEntityTwoExpectation = [self expectationWithDescription:@"import TestEntityTwo"];
    
    [self.importer importFromRecordClass:TestEntityTwo.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityTwo" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityTwoExpectation fulfill];
         
         XCTAssertEqualObjects([TestEntityTwo recordForID:@1 context:self.context error:nil].someDecimal, [NSDecimalNumber decimalNumberWithString:@"3.14159"]);
         XCTAssertEqualObjects([TestEntityTwo recordForID:@2 context:self.context error:nil].someDecimal, [NSDecimalNumber decimalNumberWithString:@"0.3"]);
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

#pragma mark - Without IDs

- (void)testMergeEmbeddedRecordsToOneWithoutID
{
    static NSString *seedDirectory = @"Seeds/testMergeEmbeddedRecordsToOneWithoutID";
    XCTestExpectation *importTestEntityTwoExpectation = [self expectationWithDescription:@"import TestEntityTwo"];
    
    [self.importer importFromRecordClass:TestEntityTwo.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityTwo" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityTwoExpectation fulfill];
         
         XCTAssertEqual([TestEntityFour allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         XCTAssertEqual([TestEntityTwo allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         
         XCTAssertEqual(((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"foo"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityTwos.count, 1);
         XCTAssertEqual(((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"bar"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityTwos.count, 1);
         
         XCTAssertEqualObjects([TestEntityTwo recordForID:@1 context:self.context error:nil].testEntityFour.someString, @"foo");
         XCTAssertEqualObjects([TestEntityTwo recordForID:@2 context:self.context error:nil].testEntityFour.someString, @"bar");
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testMergeEmbeddedRecordsToManyWithoutID
{
    static NSString *seedDirectory = @"Seeds/testMergeEmbeddedRecordsToManyWithoutID";
    XCTestExpectation *importTestEntityThreeExpectation = [self expectationWithDescription:@"import TestEntityThree"];

    [self.importer importFromRecordClass:TestEntityThree.class fromFileAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"TestEntityThree" ofType:@"json" inDirectory:seedDirectory] success:^(id result)
     {
         [importTestEntityThreeExpectation fulfill];
         
         XCTAssertEqual([TestEntityFour allRecordsSortedBy:nil context:self.context error:nil].count, 3);
         XCTAssertEqual([TestEntityThree allRecordsSortedBy:nil context:self.context error:nil].count, 2);
         
         XCTAssertEqual(((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"foo"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityThrees.count, 1);
         
         XCTAssertEqualObjects([((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"foo"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityThrees[0] id], @1);
         XCTAssertEqualObjects([((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"bar"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityThrees[0] id], @2);
         XCTAssertEqualObjects([((TestEntityFour *)[TestEntityFour recordsWhere:@{@"someString": @"baz"} requireAll:YES sortBy:nil limit:1 context:self.context error:nil].firstObject).testEntityThrees[0] id], @2);
     }
    failure:^(NSError *error)
     {
         XCTFail(@"Error importing: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}


@end
