//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 15/11/2023.
//

import Foundation
import UIKit

struct WeatherDataModel {
    
    private(set) var location: Location?
    private(set) var geocodeData: GeocodeData?
    private(set) var weatherData: WeatherData?
    private(set) var pollution: PollutionData?
    private(set) var weatherForecastData: WeatherForecastData?
    private(set) var pollutionForecastData: PollutionForecastData?
    
    private mutating func clear() {
        geocodeData = nil
        weatherData = nil
        pollution = nil
        weatherForecastData = nil
        pollutionForecastData = nil
        location = nil
    }
    
    mutating func fetch(for locationName: String) async {
        clear()
        self.geocodeData = await OpenWeatherMapAPI.getGeocodeData(locationName: locationName)
        self.location = geocodeData?[0]
        
        if let location = location {
            let lon = location.lon
            let lat = location.lat
            
            self.weatherData = await OpenWeatherMapAPI.getWeatherData(lat: lat,lon: lon)
            self.pollution = await OpenWeatherMapAPI.getPollutionData(lat: lat,lon: lon)
            self.pollutionForecastData = await OpenWeatherMapAPI.getPollutionForecastData(lat: lat,lon: lon)
            self.weatherForecastData = await OpenWeatherMapAPI.getWeatherForecastData(lat: lat,lon: lon)
            
        }
        
    }
}
    
struct OpenWeatherMapAPI {
    static private let apiKey: String = "a217d4b7c0bd4440dd30d808358561fb"
    static private let base: String = "https://api.openweathermap.org"
    
    // MARK: - Fetch function
    static func fetch<T: Codable>(
            subURLString: String,
            model: T.Type,
            // This helps differentiates using the decoding strategy in the JSONDecoder()
            val: Int = 1
    ) async throws -> T
    {
        let urlString: String = base + subURLString + "&units=metric&appid=" + apiKey
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Bad URL", code: 0, userInfo: nil)
        }
        
        let (data, _) =  try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        if (val == 1) {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        } else {
            decoder.keyDecodingStrategy = .useDefaultKeys
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    static func getGeocodeData(locationName: String) async -> GeocodeData? {
        let subString: String = "/geo/1.0/direct?q=\(locationName)&limit=1"
        return try? await Self.fetch(subURLString: subString, model: GeocodeData.self)
    }
    
    static func getWeatherData(lat: Double, lon: Double) async -> WeatherData? {
        let subString: String = "/data/2.5/weather?lat=\(lat)&lon=\(lon)"
        return try? await Self.fetch(subURLString: subString, model: WeatherData.self)
    }
    
    static func getPollutionData(lat: Double, lon: Double) async -> PollutionData? {
        let subString: String = "/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)"
        return try? await Self.fetch(subURLString: subString, model: PollutionData.self, val: 0)
    }
    
    static func getWeatherForecastData(lat: Double, lon: Double) async -> WeatherForecastData? {
        let subString: String = "/data/2.5/forecast?lat=\(lat)&lon=\(lon)"
        return try? await Self.fetch(subURLString: subString, model: WeatherForecastData.self)
    }
    
    static func getPollutionForecastData(lat: Double, lon: Double) async -> PollutionForecastData? {
        let subString: String = "/data/2.5/air_pollution/forecast?lat=\(lat)&lon=\(lon)"
        return try? await Self.fetch(subURLString: subString, model: PollutionForecastData.self, val: 0)
    }
}
   
typealias GeocodeData = [Location]

struct Location: Codable {
    var name: String
    var localNames: [String: String]?
    var lat: Double
    var lon: Double
    var country: String
    var state: String?
}
    
struct WeatherWind: Codable {
    // wind.speed
    var speed: Double
    // wind.deg
    var deg: Int
}

struct WeatherMain: Codable {
    // main.temp
    var temp: Double
    // main.feels_like
    var feelsLike: Double
    // main.pressure
    var pressure: Double
    // main.humidity
    var humidity: Double
    // main.temp_min
    var tempMin: Double
    // main.temp_max
    var tempMax: Double
}

struct WeatherClouds: Codable {
    // cloud.all
    var all: Int
}

struct WeatherWeather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct WeatherSys: Codable {
    var sunrise: Int
    var sunset: Int
}
    
// MARK: - Weather data
struct WeatherData: Codable {
    let dt: Int
    let main: WeatherMain
    let wind: WeatherWind
    let clouds: WeatherClouds
    let sys: WeatherSys
    let weather: [WeatherWeather]
    let timezone: Int?
}

struct ForecastWeatherData: Codable {
    let dt: Int
    let main: WeatherMain
}

// MARK: - Pollution data
struct PollutionData: Codable {
    var list: [PollutionListItem]
}

struct PollutionListMain: Codable {
    var aqi: Int
}

struct PollutionListItem: Codable {
    var components: PollutionComponents
    var main: PollutionListMain
    var dt: Int
}

struct PollutionComponents: Codable {
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

// MARK: - Weather forecast data
struct WeatherForecastData: Codable {
    var list: [ForecastWeatherData]
}

// MARK: - Pollution forecast data
typealias PollutionForecastData = PollutionData
