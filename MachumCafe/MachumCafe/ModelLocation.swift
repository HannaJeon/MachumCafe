//
//  ModelLocation.swift
//  MachumCafe
//
//  Created by Febrix on 2017. 5. 6..
//  Copyright © 2017년 Febrix. All rights reserved.
//

import Foundation
import ObjectMapper

class ModelLocation: Mappable {
    private(set) var latitude = Double()
    private(set) var longitude = Double()
    private(set) var address : String?
    
    required init?(map: Map) {
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    convenience init() {
        self.init(latitude: 37.4979462, longitude: 127.0254323)
    }
    
    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        address <- map["address"]
    }
    
    func setAddress(address: String) {
        self.address = address
    }
    
    
    func setLocation(latitude: Double, longitude: Double, address: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    func getLocation() -> [String : Any] {
        var locationDic = [String : Any]()
        locationDic["latitude"] = latitude
        locationDic["longitude"] = longitude
        locationDic["address"] = address
        return locationDic
    }
}

class Location {
    static let sharedInstance = Location()
    var currentLocation = ModelLocation() {
        didSet {
            NetworkCafe.getCafe()
            NetworkMap.getAddressFromCoordinate(latitude: currentLocation.latitude, longitude: currentLocation.longitude) { address in
                self.currentLocation.setAddress(address: address[0])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setLocation"), object: nil)
            }
        }
    }
}
