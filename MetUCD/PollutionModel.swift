//
//  PollutionModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import Foundation
struct PollutionModel: Codable {
    // Fields gotten from the OpenWeatherMap Air Quality API
    
    // components.co
    var co: Double
    
    // components.no
    var no: Double
    
    // components.no2
    var no2: Double
    
    // components.o3
    var o3: Double
    
    // components.pm10
    var pm10: Double
    
    // components.pm2_5
    var pm2_5: Double
    
    // components.so2
    var so2: Double
    
    // components.nh3
    var nh3: Double
}
