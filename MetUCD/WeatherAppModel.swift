//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 15/11/2023.
//

import Foundation
import UIKit

struct WeatherAppModel {
    
    private(set) var location: Location?
    private(set) var geocodeData: GeocodeData?
    private(set) var weatherData: WeatherData?
    private(set) var pollution: PollutionData?
    private(set) var weatherForecastData: WeatherForecastData?
    
    static private let apiKey: String = "a217d4b7c0bd4440dd30d808358561fb"
    static private let base: String = "https://api.openweathermap.org"
    
    mutating func fetch(for locationName: String) async {
        self.geocodeData = await Self.getGeocodeData(locationName: locationName)
        self.location = self.geocodeData![0]
        print(self.geocodeData ?? "empty") // tested OK with "Dublin:
    }
    
    // MARK: - Fetch function
    static func fetch<T: Codable>(
            subURLString: String,
            model: T.Type
    ) async throws -> T
    {
        let urlString: String = base + subURLString + "&appid=" + apiKey
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Bad URL", code: 0, userInfo: nil)
        }
        
        let (data, _) =  try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)

    }
    
    static func getGeocodeData(locationName: String) async -> GeocodeData? {
        let subString: String = "/geo/1.0/direct?q=\(locationName)&limit=1"
        return try? await Self.fetch(subURLString: subString, model: GeocodeData.self)
    }
    
//    mutating func decodeWeather(decodedWeather: WeatherData) {
//        self.weatherData = WeatherData(main: decodedWeather.main, wind: decodedWeather.wind, clouds: decodedWeather.clouds)
//    }
//    
//    mutating func decodeGeo(decodedGeo: GeocodeData) {
//        self.geocodeData = decodedGeo
//    }
//    
//    mutating func decodePollution(decodedData: PollutionData) {
//        self.pollution = decodedData
//    }
//    
//    mutating func decodeWeatherForecast(decodedData: WeatherForecastData) {
//        self.weatherForecastData = decodedData
//    }
    
    mutating func getWeatherData() async {
        let subString: String = "/data/2.5/weather?lat=\(location!.lat)&lon=\(location!.lon)"
        self.weatherData = try? await Self.fetch(subURLString: subString, model: WeatherData.self)
    }
    
    mutating func getPollutionData() async {
        let subString: String = "/data/2.5/air_pollution?lat=\(location!.lat)&lon=\(location!.lon)"
        self.pollution = try? await Self.fetch(subURLString: subString, model: PollutionData.self)
    }
    
    mutating func getWeatherForecastData() async {
        let subString: String = "/data/2.5/weather?lat=\(location!.lat)&lon=\(location!.lon)"
        self.weatherForecastData = try? await Self.fetch(subURLString: subString, model: WeatherForecastData.self)
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
    
    struct WindInfo: Codable {
        // wind.speed
        var speed: Double
        // wind.deg
        var deg: Int
    }
    
    struct MainInfo: Codable {
        // main.temp
        var temp: Double
        // main.feels_like
        var feels_like: Double
        // main.pressure
        var pressure: Double
        // main.humidity
        var humidity: Double
    }
    
    struct CloudInfo: Codable {
        // cloud.all
        var all: Int
    }
    
    // MARK: - Weather data
    struct WeatherData: Codable {
        let main: MainInfo
        let wind: WindInfo
        let clouds: CloudInfo
    }
    
    // MARK: - Pollution data
    struct PollutionData: Codable {
        
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
        
    }
}
