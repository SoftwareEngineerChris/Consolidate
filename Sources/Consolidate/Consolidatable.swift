//
//  Consolidatable.swift
//  Consolidate
//
//  Created by Chris Hargreaves on 28/09/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import Foundation

public extension Array {
    
    // MARK: Closure Type Aliases
    
    /// Closure used to consolidate two `Element` values.
    typealias Consolidate = (_ first: Element, _ second: Element) -> Element
    
    /// Closure used to decide whether two `Element` values should be consolidated.
    typealias ShouldConsolidate = (Element, Element) -> Bool
    
    // MARK: Consolidation
    
    /// Consolidates (reduces) an array of `Elements` by a `KeyPath` using a given closure.
    ///
    /// ### Example
    ///
    ///     let allTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 3.00),
    ///         TaxAmount(name: "Sales Tax", amount: 1.75),
    ///         TaxAmount(name: "Import Tax", amount: 2.30)
    ///     ]
    ///
    ///     let consolidatedTaxes = allTaxes.consolidated(by: \.name) {
    ///         TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
    ///     }
    ///
    ///     // Would result in:
    ///
    ///      let consolidatedTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 5.30),
    ///         TaxAmount(name: "Sales Tax", amount: 4.10)
    ///     ]
    ///
    /// Since the `TaxAmount` type is consolidated by name, the two entries for _"Sales Tax"_ have been consolidated
    /// into a single `TaxAmount` where their `amount` values have been added.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the property to use as a consolidation group.
    ///   - consolidating: The closure used to consolidate two `Element` values into a single `Element` value.
    ///
    /// - Returns: A new array of elements that have been consolidated by a `KeyPath` using the given `consolidating` closure.
    @inlinable
    func consolidated<GroupType: Hashable>(by keyPath: KeyPath<Element, GroupType>, using consolidating: Consolidate) -> Self {
        
        return consolidated(by: { $0[keyPath: keyPath] == $1[keyPath: keyPath] }, using: consolidating)
    }
    
    
    /// Consolidates (reduces) an array of `Elements`, by a `KeyPath` using a given closure, into a single element.
    ///
    /// ### Example
    ///
    ///     let allTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 3.00),
    ///         TaxAmount(name: "Import Tax", amount: 2.30)
    ///     ]
    ///
    ///     // The next line would result in TaxAmount(name: "Import Tax", amount: 5.30)
    ///
    ///     let consolidatedTaxes = allTaxes.consolidated(by: \.name) {
    ///         TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
    ///     }
    ///
    /// Since the `TaxAmount` type is consolidated by name, the two entries for _"Import Tax"_ have been consolidated
    /// into a single `TaxAmount` where their `amount` values have been added.
    ///
    ///
    ///     let allTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 3.00),
    ///         TaxAmount(name: "Sales Tax", amount: 1.75),
    ///         TaxAmount(name: "Import Tax", amount: 2.30)
    ///     ]
    ///
    ///     // The next line would throw
    ///
    ///     let consolidatedTaxes = allTaxes.consolidated(by: \.name) {
    ///         TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
    ///     }
    ///
    /// Since the `TaxAmount` entries would consolidate to two elements (Import Tax and Sales Tax) the example above would throw
    /// the error `ConsolidationError.couldNotBeConolidatedIntoSingleElement`.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the property to use as a consolidation group.
    ///   - consolidating: The closure used to consolidate two `Element` values into a single `Element` value.
    ///
    /// - Returns: A single element representing the consolidation by a `KeyPath` using the given `consolidating` closure.
    /// - Throws: `ConsolidationError.couldNotBeConolidatedIntoSingleElement` error if the array does not consolidate into a single element.
    @inlinable
    func consolidatedIntoSingle<GroupType: Hashable>(by keyPath: KeyPath<Element, GroupType>, using consolidating: Consolidate) throws -> Element {
        
        let consolidatedArray = consolidated(by: keyPath, using: consolidating)
        
        guard consolidatedArray.count == 1, let consolidatedSingle = consolidatedArray.first else {
            throw ConsolidationError.couldNotBeConolidatedIntoSingleElement
        }
        
        return consolidatedSingle
    }

    /// Consolidates (reduces) an array of `Elements` grouped by the result of a closure
    /// combined using another closure.
    ///
    /// ### Example
    ///
    ///     let allTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 3.00),
    ///         TaxAmount(name: "Sales Tax", amount: 1.75),
    ///         TaxAmount(name: "Import Tax", amount: 2.30)
    ///     ]
    ///
    ///     let consolidatedTaxes = allTaxes.consolidated(by: { $0.name == $1.name }) {
    ///         TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
    ///     }
    ///
    ///     // Would result in:
    ///
    ///      let consolidatedTaxes = [
    ///         TaxAmount(name: "Import Tax", amount: 5.30),
    ///         TaxAmount(name: "Sales Tax", amount: 4.10)
    ///     ]
    ///
    /// Since the `TaxAmount` type is consolidated by name, the two entries for _"Sales Tax"_ have been consolidated
    /// into a single `TaxAmount` where their `amount` values have been added.
    ///
    /// - Parameters:
    ///   - comparison: The closure used to decide whether two `Element` values should be consolidated.
    ///   - consolidating: The closure used to consolidate two `Element` values into a single `Element` value.
    ///
    /// - Returns: A new array of elements that have been grouped by the result of a closure combined using another closure.
    @inlinable
    func consolidated(by comparison: ShouldConsolidate, using consolidating: Consolidate) -> Self {
        
        return reduce([]) { (result, element) -> [Element] in
            
            if let existingGroupIndex = result.firstIndex(where: { comparison($0, element) }) {
                
                var mutableResult = result
                
                mutableResult[existingGroupIndex] = consolidating(result[existingGroupIndex], element)
                
                return mutableResult
            }
            
            return result + [element]
        }
    }
    
    // MARK: Errors
    
    /// Errors that can occur during consolidation
    enum ConsolidationError: Error {
        /// Thrown when attempting to concolidate to a single element, but the collection can not be consolidated to a single element.
        case couldNotBeConolidatedIntoSingleElement
    }
}

/// A type implementing `Consolidatable` allows an array of its values to be combined by
/// `consolidationGroup` into a new array using the type's `consolidate(with:)` function.
public protocol Consolidatable {
    
    /// The group in which an element should belong to when consolidated
    var consolidationGroup: AnyHashable { get }
    
    /// The implementation of how two values of the same type are consolidated into a single value of that type
    /// - parameters:
    ///   - other: Another value of the same type.
    /// - returns: A value representing the consolidation of `self` and `other`
    func consolidate(with other: Self) -> Self
}

public extension Array where Element: Consolidatable {
    
    // MARK: Where Element type implements Consolidatable
    
    /// Consolidates (reduces) an array of `Elements` that implement the `Consolidatable` protocol.
    ///
    /// ### Example
    ///
    ///     struct TaxAmount: Consolidatable {
    ///
    ///         let name: String
    ///         let amount: Decimal
    ///
    ///         var consolidationGroup: AnyHashable {
    ///             return name
    ///         }
    ///
    ///         func consolidate(with other: Self) -> Self {
    ///             return .init(name: name, amount: amount + other.amount)
    ///         }
    ///     }
    ///
    /// The above implementation would consolidate like this:
    ///
    ///     let taxes = [
    ///         TaxAmount(name: "Import Tax", amount: 3.00),
    ///         TaxAmount(name: "Sales Tax", amount: 1.75),
    ///         TaxAmount(name: "Import Tax", amount: 2.30)
    ///     ].consolidated()
    ///
    ///     // Results in:
    ///
    ///     let taxes = [
    ///         TaxAmount(name: "Import Tax", amount: 5.30),
    ///         TaxAmount(name: "Sales Tax", amount: 4.10)
    ///     ]
    ///
    /// Since the `TaxAmount` type is consolidated by name, the two entries for _"Sales Tax"_ have been consolidated
    /// into a single `TaxAmount` where their `amount` values have been added.
    ///
    /// - returns: A new array of elements that have been consolidated by group (`consolidationGroup`) using
    /// the implementation of  `consolidate(with:)`
    @inlinable
    func consolidated() -> Self {
        
        return consolidated(by: { $0.consolidationGroup == $1.consolidationGroup }, using: { $0.consolidate(with: $1) })
    }
}
