//
//  TestEntityTwo+CoreDataProperties.swift
//  Converge
//
//  Created by David (work) on 1/11/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TestEntityTwo {

    @NSManaged var id: NSNumber?
    @NSManaged var someDate: NSDate?
    @NSManaged var someDecimal: NSDecimalNumber?
    @NSManaged var testEntityOne: TestEntityOne?

}
