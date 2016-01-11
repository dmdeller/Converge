//
//  Importer.swift
//  Converge
//
//  Created by David (work) on 1/11/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import CoreData

public class Importer {
    
    var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func importFrom(recordClass: AnyClass, filePath: String, success: (result: AnyObject?) -> Void, failure: (error: NSError) -> Void) {
        
    }
    
}
