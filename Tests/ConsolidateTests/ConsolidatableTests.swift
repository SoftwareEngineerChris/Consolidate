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
    
    // MARK: Consolidatable Protocol Implementation
    
    func test_emptyArray_returnsEmptyArray() {
    
        let consolidatedTaxes: [TaxAmount] = [].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [])
    }
    
    func test_usingConsolidatableProtocol_noConsolidabaleValues_doesNotConsolidate() {
    
        let consolidatedTaxes = [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Export Tax", amount: 2.30),
            TaxAmount(tax: "Income Tax", amount: 2.35)
        ].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Export Tax", amount: 2.30),
            TaxAmount(tax: "Income Tax", amount: 2.35)
        ])
    }
    
    func test_usingConsolidatableProtocol_consolidabaleValues_consolidates() {

        let consolidatedTaxes = [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Import Tax", amount: 2.30)
        ].consolidated()
        
        XCTAssertEqual(consolidatedTaxes, [
            TaxAmount(tax: "Import Tax", amount: 5.30),
            TaxAmount(tax: "Sales Tax", amount: 1.75)
        ])
    }
    
    // MARK: By KeyPath
    
    func test_byKeyPath_consolidates() {
    
        let taxes = [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Import Tax", amount: 2.30)
        ].consolidated(by: \.tax) {
            TaxAmount(tax: $0.tax, amount: $0.amount + $1.amount)
        }
        
        XCTAssertEqual(taxes, [
            TaxAmount(tax: "Import Tax", amount: 5.30),
            TaxAmount(tax: "Sales Tax", amount: 1.75)
        ])
    }
    
    func test_byClosure_consolidates() {
    
        let taxes = [
            TaxAmount(tax: "Import Tax", amount: 3.00),
            TaxAmount(tax: "Sales Tax", amount: 1.75),
            TaxAmount(tax: "Import Tax", amount: 2.30)
        ].consolidated(by: { $0.tax == $1.tax }) {
            TaxAmount(tax: $0.tax, amount: $0.amount + $1.amount)
        }
        
        XCTAssertEqual(taxes, [
            TaxAmount(tax: "Import Tax", amount: 5.30),
            TaxAmount(tax: "Sales Tax", amount: 1.75)
        ])
    }

    static var allTests = [
        ("test_emptyArray_returnsEmptyArray", test_emptyArray_returnsEmptyArray),
        ("test_usingConsolidatableProtocol_noConsolidabaleValues_doesNotConsolidate", test_usingConsolidatableProtocol_noConsolidabaleValues_doesNotConsolidate),
        ("test_usingConsolidatableProtocol_consolidabaleValues_consolidates", test_usingConsolidatableProtocol_consolidabaleValues_consolidates),
        ("test_byKeyPath_consolidates", test_byKeyPath_consolidates),
        ("test_byClosure_consolidates", test_byClosure_consolidates)
    ]
    
    // MARK: Test Fixtures

    private struct TaxAmount: Equatable, Consolidatable {
        
        let tax: String
        let amount: Decimal
        
        var consolidationGroup: AnyHashable {
            return tax
        }
        
        func consolidate(with other: Self) -> Self {
            return .init(tax: tax, amount: amount + other.amount)
        }
    }
}
