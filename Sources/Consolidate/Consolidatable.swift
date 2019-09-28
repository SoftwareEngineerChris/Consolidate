//
//  Consolidatable.swift
//  Consolidate
//
//  Created by Chris Hargreaves on 28/09/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import Foundation

public protocol Consolidatable {
    
    var consolidationGroup: AnyHashable { get }
    
    func consolidate(with other: Self) -> Self
    
}

public extension Array where Element: Consolidatable {
    
    func consolidated() -> Self {
        
        return reduce([]) { (result, element) -> [Element] in
            
            if let existingGroupIndex = result.firstIndex(where: { $0.consolidationGroup == element.consolidationGroup }) {
                
                var mutableResult = result
                
                mutableResult[existingGroupIndex] = result[existingGroupIndex].consolidate(with: element)
                
                return mutableResult
            }
            
            return result + [element]
        }
    }
}
