//
//  Config.swift
//  MachumCafe
//
//  Created by HannaJeon on 2017. 10. 27..
//  Copyright © 2017년 Febrix. All rights reserved.
//

import Foundation

class Config {
    static private let plist: NSDictionary? = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) else { return nil }
        return plist
    }()
    
    static let standardURL: String = {
        return plist?["URL"] as! String
    }()
    
    static let googleMapKey: String = {
        return plist?["GoogleMapKey"] as! String
    }()
    
    static let geoCodingKey: String = {
        return plist?["GeoCodingAPIKey"] as! String
    }()
}
