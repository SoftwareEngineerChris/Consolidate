//
//  ConsolidatableTests.swift
//  Consolidate
//
//  Created by Chris Hargreaves on 28/09/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import XCTest
@testable import Consolidate

final class ConsolidatableTests: XCTestCase {
    
    func test_emptyArray_returnsEmptyArray() {
    
        let consolidatedTaxes: [TaxAmount] = [].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [])
    }
    
    func test_noConsolidabaleValues_doesNotConsolidate() {
    
        let importTax = TaxAmount(tax: "Import Tax", amount: 3.00)
        let salesTax = TaxAmount(tax: "Sales Tax", amount: 1.75)
        let exportTax = TaxAmount(tax: "Export Tax", amount: 2.30)
        let incomeTax = TaxAmount(tax: "Income Tax", amount: 2.35)
        
        let consolidatedTaxes = [
            importTax,
            salesTax,
            exportTax,
            incomeTax
        ].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Export Tax", amount: 2.30),
            TaxAmount(tax: "Income Tax", amount: 2.35)
        ])
    }
    
    func test_multipleConsolidabaleValues_consolidates() {
    
        let importTaxA = TaxAmount(tax: "Import Tax", amount: 3.00)
        let salesTaxA = TaxAmount(tax: "Sales Tax", amount: 1.75)
        let importTaxB = TaxAmount(tax: "Import Tax", amount: 2.30)
        let salesTaxB = TaxAmount(tax: "Sales Tax", amount: 2.35)
        
        let consolidatedTaxes = [
            importTaxA,
            salesTaxA,
            importTaxB,
            salesTaxB
        ].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [
            TaxAmount(tax: "Import Tax", amount: 5.30),
            TaxAmount(tax: "Sales Tax", amount: 4.10)
        ])
    }

    static var allTests = [
        ("test_noConsolidabaleValues_doesNotConsolidate", test_noConsolidabaleValues_doesNotConsolidate),
        ("test_multipleConsolidabaleValues_consolidates", test_multipleConsolidabaleValues_consolidates),
    ]
}

// MARK: Test Fixtures

struct TaxAmount: Equatable, Consolidatable {
    
    let tax: String
    let amount: Decimal
    
    var consolidationGroup: AnyHashable {
        return tax
    }
    
    func consolidate(with other: Self) -> Self {
        return .init(tax: tax, amount: amount + other.amount)
    }
}
