//
//  NSPredicate+AcceptNilValues.swift
//  Converge
//
//  Created by David (work) on 1/12/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import Foundation

extension NSPredicate {
    
    convenience init(format predicateFormat: String, argumentArray arguments: [AnyObject?]?) {
        // NSPredicate.init(format, argumentArray) specifies argumentArray as [AnyObject], which means the array can't contain nil, even though that would be a perfectly cromulent predicate.
        // So, let's stick an NSNull in there like it's 1999
        let wrappedArguments: [AnyObject]? = arguments?.map { (argument: AnyObject?) -> AnyObject in
            if argument == nil {
                return NSNull()
            } else {
                return argument!
            }
        }
        
        self.init(format: predicateFormat, argumentArray: wrappedArguments)
    }
    
}
