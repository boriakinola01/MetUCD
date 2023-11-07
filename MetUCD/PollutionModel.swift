//
//  PollutionModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import Foundation

struct PollutionModel: Codable {
    // Fields gotten from the OpenWeatherMap Air Quality API
    // https://api.openweathermap.org/data/2.5/air_pollution
    
    // list[0].components.co
    var co: Double
    
    // list[0].components.no
    var no: Double
    
    // list[0].components.no2
    var no2: Double
    
    // list[0].components.o3
    var o3: Double
    
    // list[0].components.pm10
    var pm10: Double
    
    // list[0].components.pm2_5
    var pm2_5: Double
    
    // list[0].components.so2
    var so2: Double
    
    // list[0].components.nh3
    var nh3: Double
}
