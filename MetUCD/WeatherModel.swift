//
//  WeatherModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import Foundation

struct WeatherModel: Codable {
    
    // All fields gotten from the OpenWeather API
    
    struct Wind: Codable {
        // current.wind_speed
        var speed: Double
        // current.wind_deg
        var direction: Int
    }
    
    // current.temp
    var temp: Double
    
    // current.feels_like
    var feelsLike: Double
    
    // current.clouds
    var cloudCoverage: Double
    
    // Wind information
    var wind: Wind
    
    // currrent.pressure
    var pressure: Double
    
    // current.humidity
    var humidity: Double
}
