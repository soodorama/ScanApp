//
//  WalmartItem.swift
//  Scan
//
//  Created by Isabell Frischmann on 9/18/18.
//  Copyright © 2018 Isabell Frischmann. All rights reserved.
//

import Foundation
import CoreData

//protocol WalmartItemDelegate: class {
//    func updateContext(data: [String:Any])
//}

class WalmartItem {

    let id: Int
    let upc: String
    let name: String
    let price: Double
    let brand: String
    let largeImage: String
    let desc: String
    let isInStock: Bool
    let isOnClearance: Bool
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let id = json["itemId"] as? Int else {throw SerializationError.missing("id is missing")}
        guard let upc = json["upc"] as? String else {throw SerializationError.missing("upc is missing")}
        guard let name = json["name"] as? String else {throw SerializationError.missing("name is missing")}
        guard let price = json["salePrice"] as? Double else {throw SerializationError.missing("price is missing")}
        guard let brand = json["brandName"] as? String else {throw SerializationError.missing("brandName is missing")}
        guard let largeImage = json["largeImage"] as? String else {throw SerializationError.missing("largeImage is missing")}
        guard let desc = json["shortDescription"] as? String else {throw SerializationError.missing("price is missing")}
        guard let isInStock = json["stock"] as? String else {throw SerializationError.missing("isInStock is missing")}
        guard let isOnClearance = json["clearance"] as? Bool else {throw SerializationError.missing("isOnClearance is missing")}
        
        self.id = id
        self.upc = upc
        self.name = name
        self.price = price
        self.brand = brand
        self.largeImage = largeImage
        self.desc = desc
        if isInStock == "Not Available" {
            self.isInStock = false
        }
        else {
            self.isInStock = true
        }
        self.isOnClearance = isOnClearance
    
    }
    
}
