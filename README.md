# Consolidate

[![Build Status](https://app.bitrise.io/app/2401d8d24819bc28/status.svg?token=rpSxCpEdigqkV5zTb-dRog)](https://app.bitrise.io/app/2401d8d24819bc28)
[![Docs](https://softwareengineerchris.github.io/Consolidate/badge.svg)](https://softwareengineerchris.github.io/Consolidate)
[![SPM](https://img.shields.io/badge/SPM-Supported-informational)](#)

## Installation

### Swift Package Manager
```swift
dependencies: [
   .package(url: "https://github.com/SoftwareEngineerChris/Consolidate.git", from: "1.0.0")
]
```

## Usage Example

### Using KeyPath

```swift
let allTaxes = [
    TaxAmount(name: "Import Tax", amount: 3.00),
    TaxAmount(name: "Sales Tax", amount: 1.75),
    TaxAmount(name: "Import Tax", amount: 2.30)
]

let consolidatedTaxes = allTaxes.consolidated(by: \.name) {
    TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
}

// Would result in:

let consolidatedTaxes = [
    TaxAmount(name: "Import Tax", amount: 5.30),
    TaxAmount(name: "Sales Tax", amount: 4.10)
]
```

### Using Closures

```swift
let allTaxes = [
    TaxAmount(name: "Import Tax", amount: 3.00),
    TaxAmount(name: "Sales Tax", amount: 1.75),
    TaxAmount(name: "Import Tax", amount: 2.30)
]

let consolidatedTaxes = allTaxes.consolidated(by: { $0.name == $1.name }) {
    TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
}

// Would result in:

 let consolidatedTaxes = [
    TaxAmount(name: "Import Tax", amount: 5.30),
    TaxAmount(name: "Sales Tax", amount: 4.10)
]
```

### Using Consolidatable Protocol

```swift
struct TaxAmount: Consolidatable {

    let name: String
    let amount: Decimal

    var consolidationGroup: AnyHashable {
        return name
    }

    func consolidate(with other: Self) -> Self {
        return .init(name: name, amount: amount + other.amount)
    }
}
```

The above implementation would consolidate like this:


```swift
let taxes = [
    TaxAmount(name: "Import Tax", amount: 3.00),
    TaxAmount(name: "Sales Tax", amount: 1.75),
    TaxAmount(name: "Import Tax", amount: 2.30)
].consolidated()

// Results in:

let taxes = [
    TaxAmount(name: "Import Tax", amount: 5.30),
    TaxAmount(name: "Sales Tax", amount: 4.10)
]
```

### Consolidate into single item (throws if unable to)

There may be times where you want to consolidate a collection of elements into a single element.
For this, there exists the array extension `consolidatedIntoSingle`. It is functionally similar to the other
consolidation methods, except its return type is of type `Element` rather than `[Element]`. This means that
the collection has to be consolidatable to a single element. If the collection can't be consolidated to a single
element, then the method will throw the error `ConsolidationError.couldNotBeConolidatedIntoSingleElement`.

```swift
let allTaxes = [
    TaxAmount(name: "Import Tax", amount: 3.00),
    TaxAmount(name: "Sales Tax", amount: 1.75),
    TaxAmount(name: "Import Tax", amount: 2.30)
]

// The line below would throw `ConsolidationError.couldNotBeConolidatedIntoSingleElement`,
// since the taxes can't be consolidated into a single tax when using the name key-path.

let consolidatedTax = try allTaxes.consolidatedIntoSingle(by: \.name) {
    TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
}
```

Whereas:

```swift
let allTaxes = [
    TaxAmount(name: "Import Tax", amount: 3.00),
    TaxAmount(name: "Import Tax", amount: 2.30)
]

let consolidatedTax = try allTaxes.consolidatedIntoSingle(by: \.name) {
    TaxAmount(tax: $0.name, amount: $0.amount + $1.amount)
}

// Since all taxes have the name "Import Tax", they can be consolidated into a single tax
// when using the name key-path. The result would be:

let consolidatedTax = [
    TaxAmount(name: "Import Tax", amount: 5.30)
]
```
