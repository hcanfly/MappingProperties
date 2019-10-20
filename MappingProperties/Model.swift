//
//  Model.swift
//  TenX
//
//  Created by Gary on 3/11/17.
//  Copyright © 2019 Gary Hanson. All rights reserved.
//

import Foundation
import MapKit


enum PropertyNotes {
    case doNotDisturb
    case valueBasedBid
    case cashOnlyPurchase
}

enum AssetType {
    case residential
}

enum PropertyType : Int {
    case sfr
    case condo
}

struct Property {
    
    let street: String
    let city: String
    let state: String
    let zip: String
    let county: String
    
    let latitude: Float
    let longitude: Float
    let coordinates: CLLocationCoordinate2D
    let location: CLLocation
    
    let notes: [PropertyNotes]
    let assetType: AssetType
    let propertyType: PropertyType
    let beds: Int
    let baths: Float
    let sqFeet: Int
    let yearBuilt: Int
    let foreclosureTrusteeNumber: String
    let estimatedOpeningBid: Double
    let totalEstimatedDebt: Double
    let apn: String
    let eventItemNumber: String
    let propertyId: Int
    let images: [UIImage]
}

// note: this uses John Sundell's Unbox package which is now deprecated (see compile warnings in file) due to
// Apple's implementation of Codable. Not worth updating for this sample code. If you like the idea, he had
// a new package which uses Codable: https://github.com/JohnSundell/Codextended

extension Property: Unboxable {
    init (unboxer: Unboxer) throws {
        street = try unboxer.unbox(key: "street")
        city = try unboxer.unbox(key: "city")
        state = try unboxer.unbox(key: "state")
        zip = try unboxer.unbox(key: "zip")
        county = try unboxer.unbox(key: "county")
        
        latitude = try unboxer.unbox(key: "latitude")
        longitude = try unboxer.unbox(key: "longitude")
        coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        notes = [.doNotDisturb, .valueBasedBid, .cashOnlyPurchase]
        assetType = .residential
        let pt: Int = try unboxer.unbox(key: "propertyType")
        propertyType = PropertyType(rawValue: pt)!
        beds = try unboxer.unbox(key: "beds")
        baths = try unboxer.unbox(key: "baths")
        sqFeet = try unboxer.unbox(key: "sqFeet")
        yearBuilt = try unboxer.unbox(key: "yearBuilt")
        propertyId = try unboxer.unbox(key: "propertyId")
        
        images = Model.imagesFor(property: propertyId)
        
        foreclosureTrusteeNumber = try unboxer.unbox(key: "foreclosureTrusteeNumber")
        estimatedOpeningBid = try unboxer.unbox(key: "estimatedOpeningBid")
        totalEstimatedDebt = try unboxer.unbox(key: "totalEstimatedDebt")
        apn = try unboxer.unbox(key: "apn")
        eventItemNumber = try unboxer.unbox(key: "eventItemNumber")
        
    }
    
}

struct Model {
    
    static func imagesFor(property: Int) -> [UIImage] {
        var images = [UIImage]()
        var counter = 1
        
        while true {
            if let image = UIImage(named: "PropertyImages/\(property)/" + String(counter) + ".jpg") {
                images.append(image)
                counter += 1
            } else {
                break
            }
        }
        
        return images
    }


    static func getTestData() -> [Property]? {
        do {
            let props: [Property] = try unbox(dictionary: propertiesJSON, atKey: "properties")
            
            return props
        }
        catch {
            print("big time error")
            
            return nil
        }
    }
    
    @available(*, unavailable) private init() {}
    
}


//MARK: Test Data - not real!
let propertiesJSON: UnboxableDictionary = [
    "properties" : [
        [
            "street" : "1383 Alviso St",
            "city" : "Santa Clara",
            "state" : "California",
            "zip" : "95050",
            "county" : "Santa Clara",
            "latitude" : 37.354364,
            "longitude" : -121.943549,
            "propertyType" : 0,
            "beds" : 2,
            "baths" : 1,
            "sqFeet" : 960,
            "yearBuilt" : 1958,
            "propertyId" : 0,
            "foreclosureTrusteeNumber" : "16-00185-CI-CA",
            "estimatedOpeningBid" : 320000.0,
            "totalEstimatedDebt" : 0.0,
            "apn" : "228-28-044",
            "eventItemNumber" : "E8015-3588"
        ],
        [
            "street" : "1802 Park Vista Circle",
            "city" : "Santa Clara",
            "state" : "California",
            "zip" : "95050",
            "county" : "Santa Clara",
            "latitude" : 37.355943,
            "longitude" : -121.956027,
            "propertyType" : 0,
            "beds" : 2,
            "baths" : 2,
            "sqFeet" : 846,
            "yearBuilt" : 1956,
            "propertyId" : 1,
            "foreclosureTrusteeNumber" : "13-2829-13",
            "estimatedOpeningBid" : 330000.0,
            "totalEstimatedDebt" : 0.0,
            "apn" : "228-42-684",
            "eventItemNumber" : "E8112-2523"
        ],
        [
            "street" : "977 Warburton Ave 301",
            "city" : "Santa Clara",
            "state" : "California",
            "zip" : "95050",
            "county" : "Santa Clara",
            "latitude" : 37.357934,
            "longitude" : -121.948149,
            "propertyType" : 1,
            "beds" : 2,
            "baths" : 2,
            "sqFeet" : 876,
            "yearBuilt" : 1987,
            "propertyId" : 2,
            "foreclosureTrusteeNumber" : "16-00089-CI-CA",
            "estimatedOpeningBid" : 340000.0,
            "totalEstimatedDebt" : 0.0,
            "apn" : "224-27-084",
            "eventItemNumber" : "E8292-6508"
        ],
        [
            "street" : "1687 Roll St",
            "city" : "Santa Clara",
            "state" : "California",
            "zip" : "95050",
            "county" : "Santa Clara",
            "latitude" : 37.354529,
            "longitude" : -121.962966,
            "propertyType" : 0,
            "beds" : 3,
            "baths" : 2,
            "sqFeet" : 1427,
            "yearBuilt" : 1951,
            "propertyId" : 3,
            "foreclosureTrusteeNumber" : "14-2449-11",
            "estimatedOpeningBid" : 0.0,
            "totalEstimatedDebt" : 996870.73,
            "apn" : "224-17-006",
            "eventItemNumber" : "E8388-12501"
        ],
        [
            "street" : "725 Pershing Avenue",
            "city" : "San Jose",
            "state" : "California",
            "zip" : "95126",
            "county" : "Santa Clara",
            "latitude" : 37.337552,
            "longitude" : -121.910796,
            "propertyType" : 0,
            "beds" : 3,
            "baths" : 1,
            "sqFeet" : 1364,
            "yearBuilt" : 1926,
            "propertyId" : 4,
            "foreclosureTrusteeNumber" : "15-003261-FC01",
            "estimatedOpeningBid" : 440000.0,
            "totalEstimatedDebt" : 0.0,
            "apn" : "261-05-003",
            "eventItemNumber" : "E8349-12507"
        ],
        [
            "street" : "354 Menker Avenue",
            "city" : "San Jose",
            "state" : "California",
            "zip" : "95128",
            "county" : "Santa Clara",
            "latitude" : 37.322410,
            "longitude" : -121.921339,
            "propertyType" : 0,
            "beds" : 2,
            "baths" : 1,
            "sqFeet" : 1220,
            "yearBuilt" : 1920,
            "propertyId" : 5,
            "foreclosureTrusteeNumber" : "CA08006204-14",
            "estimatedOpeningBid" : 0.0,
            "totalEstimatedDebt" : 809750.43,
            "apn" : "277-16-022",
            "eventItemNumber" : "E8445-12000"
        ],
        [
            "street" : "897 Georgetown Place",
            "city" : "San Jose",
            "state" : "California",
            "zip" : "95126",
            "county" : "Santa Clara",
            "latitude" : 37.328537,
            "longitude" : -121.905864,
            "propertyType" : 1,
            "beds" : 3,
            "baths" : 3,
            "sqFeet" : 1463,
            "yearBuilt" : 2004,
            "propertyId" : 6,
            "foreclosureTrusteeNumber" : "CA08006413-14",
            "estimatedOpeningBid" : 510000.0,
            "totalEstimatedDebt" : 885113.23,
            "apn" : "261-58-053",
            "eventItemNumber" : "E8388-12003"
        ],
    ]
]
