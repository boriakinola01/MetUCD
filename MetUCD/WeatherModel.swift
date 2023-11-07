//
//  WeatherModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import Foundation

struct WeatherModel: Codable {
    
    // All fields gotten from the OpenWeather API
    // https://api.openweathermap.org/data/2.5/weather
    
    struct Wind: Codable {
        // wind.speed
        var speed: Double
        // wind.deg
        var direction: Int
    }
    
    // main.temp
    var temp: Double
    
    // main.feels_like
    var feelsLike: Double
    
    // clouds.all
    var cloudCoverage: Double
    
    // Wind information
    var wind: Wind
    
    // main.pressure
    var pressure: Double
    
    // main.humidity
    var humidity: Double
}
