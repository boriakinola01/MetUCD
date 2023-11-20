//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 20/11/2023.
//

import Foundation

@Observable class WeatherViewModel {
    var location: String = ""
    
    // MARK: data model
    private var dataModel = WeatherDataModel()
    
    
    func fetchData() {
        Task {
            await dataModel.fetch(for: location)
        }
    }
    
    var geoInfo: GeoInfo? {
        getGeoInfo()
    }
    
    var weatherInfo: WeatherInfo? {
        getWeatherInfo()
    }
    
    var pollutionInfo: PollutionInfo? {
        getPollutionInfo()
    }
    
    struct GeoInfo {
        var coordinates: String
        var sunrise: String
        var sunset: String
        var timeDifference: String
    }
    
    struct WeatherInfo {
        var temperature: String
        var tempLowHigh: String
        var tempFeels: String
        var cloudCoverage: String
        var windSpeedDirection: String
        var humidity: String
        var pressure: String
        var description: String
    }
    
    struct PollutionInfo {
        var items: [String: Double]
        var quality: String
    }
    
    private func getGeoInfo() -> GeoInfo? {
        // Get the coordinates in Degrees Minutes and Seconds format
        if let geoCode = dataModel.geocodeData {
            let (latDMS, lonDMS) = convertToDMS(latitude: geoCode.first!.lat, longitude: geoCode.first!.lon)
            let coords = "\(latDMS), \(lonDMS)"
            
            let sunrise: String = convertUnixTimestampToDate(timestamp: (dataModel.weatherData?.sys.sunrise)!)
            let sunset : String = convertUnixTimestampToDate(timestamp: (dataModel.weatherData?.sys.sunset)!)
            let timeDiff: String = formatTimezoneOffset(seconds: dataModel.weatherData!.timezone)
            
            return GeoInfo(coordinates: coords, 
                           sunrise: sunrise,
                           sunset: sunset,
                           timeDifference: timeDiff
            )
        }
        
       return nil
    }
    
    private func getWeatherInfo() -> WeatherInfo? {
        
        if let weather = dataModel.weatherData {
            
            return WeatherInfo(temperature: "\(Int(weather.main.temp))",
                               tempLowHigh: "(L:\(Int(weather.main.tempMin))ºH:\(Int(weather.main.tempMax)))",
                               tempFeels: "Feels \(Int(weather.main.feelsLike))º",
                               cloudCoverage: "\(Int(weather.main.temp))% coverage",
                               windSpeedDirection: "\(Int(weather.wind.speed))km/hr, dir: \(weather.wind.deg)º",
                               humidity: "\(Int(weather.main.humidity))%",
                               pressure: "\(Int(weather.main.pressure)) hPa",
                               description: "\(weather.weather[0].description)")
        }
        return nil
    }
    
    private func getPollutionInfo() -> PollutionInfo? {
        if let pollution = dataModel.pollution {
            let components = pollution.list[0].components
            let mainIndex = pollution.list[0].main.aqi
            let items: [String: Double] = [
                "CO": components.co,
                "NO": components.no,
                "NH3": components.nh3,
                "O3": components.o3,
                "PM10": components.pm10,
                "PM2.5": components.pm2_5,
                "SO2": components.so2,
                "NO2": components.no2
            ]
            
            let pollutionIndex: [Int: String] = [
                1: "Good",
                2: "Fair",
                3: "Moderate",
                4: "Poor",
                5: "Very Poor"
            ]
            
            return PollutionInfo(items: items, quality: pollutionIndex[mainIndex]!)
            
        }
        
        
        return nil
    }
}

// MARK: - Misc
func convertToDMS(latitude: Double, longitude: Double) -> (String, String) {
    func convertCoordinate(_ coordinate: Double, isLatitude: Bool) -> String {
        let absCoord = abs(coordinate)
        let degrees = Int(absCoord)
        let minutes = Int((absCoord - Double(degrees)) * 60)
        let seconds = Int((absCoord * 3600).truncatingRemainder(dividingBy: 60))
        let direction = isLatitude ? (coordinate > 0 ? "N" : "S") : (coordinate > 0 ? "E" : "W")
        return "\(degrees)º\(minutes)'\(seconds)\"\(direction)"
    }

    let latString = convertCoordinate(latitude, isLatitude: true)
    let lonString = convertCoordinate(longitude, isLatitude: false)

    return (latString, lonString)
}

func convertUnixTimestampToDate(timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm" // Customize the date format as needed
    return dateFormatter.string(from: date)
}

func formatTimezoneOffset(seconds: Int) -> String {
    let hoursDecimal = Double(seconds) / 3600.0 // Convert seconds to decimal hours
    let sign = (seconds >= 0) ? "+" : "-" // Determine the sign of the offset
    return String(format: "%@%.1fH", sign, hoursDecimal)
}
