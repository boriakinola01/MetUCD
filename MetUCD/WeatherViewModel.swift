//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 20/11/2023.
//

import Foundation
import CoreLocation
import MapKit

@Observable class WeatherViewModel : NSObject, CLLocationManagerDelegate {
    var location: String = ""
    var locationManager = CLLocationManager()
    
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.setup()
    }
    
    // MARK: data model
    private var dataModel = WeatherDataModel()
    let pollutionIndex: [Int: String] = [
        1: "Good",
        2: "Fair",
        3: "Moderate",
        4: "Poor",
        5: "Very Poor"
    ]
    
    func fetchData() {
        if !location.isEmpty {
            Task {
                await dataModel.fetch(for: location,
                                      longitude: mapInfo!.longitude,
                                      latitude: mapInfo!.latitude)
            }
        } else {
            if let location = locationManager.location {
                Task {
                    await dataModel.fetch(for: "",
                                          longitude: location.coordinate.longitude,
                                          latitude: location.coordinate.latitude)
                }
            }
        }
    }
    
    var mapInfo: MapInfo? {
        get {return getMapInfo()}
        set {}
    }
    
    var region: MKCoordinateRegion? {
        get {return getRegion()}
        set {}
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
    
    var weatherForecastListInfo: WeatherForecastList? {
        getWeatherForecastListInfo()
    }
    
    var pollutionForecastListInfo: PollutionForecastList? {
        getPollutionForecastList()
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
    
    struct WeatherForecastInfo: Hashable {
        var dayOfWeek: String
        var tempLowHigh: String
        var hourIconUrls: [HourIconUrl]
    }
    
    struct PollutionForecastInfo: Identifiable {
        var id = UUID()
        var day: String
        var index: String
    }
    
    struct MapInfo {
        var longitude: Double
        var latitude: Double
    }
    
    typealias WeatherForecastList = [WeatherForecastInfo]
    
    typealias PollutionForecastList = [PollutionForecastInfo]
    
    struct HourIconUrl: Hashable {
        var hour: String
        var url : URL
    }
    
    private func getGeoInfo() -> GeoInfo? {
        // Get the coordinates in Degrees Minutes and Seconds format
        if let geoCode = dataModel.geocodeData {
            
            let (latDMS, lonDMS) = convertToDMS(latitude: geoCode.first!.lat, longitude: geoCode.first!.lon)
            let coords = "\(latDMS), \(lonDMS)"
            
            let sunrise: String = convertUnixTimestampToDate(timestamp: (dataModel.weatherData?.sys.sunrise)!)
            let sunset : String = convertUnixTimestampToDate(timestamp: (dataModel.weatherData?.sys.sunset)!)
            let timeDiff: String = formatTimezoneOffset(seconds: dataModel.weatherData!.timezone!)
            
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
            
            return WeatherInfo(temperature: "\(Int(weather.main.temp))º",
                               tempLowHigh: "(L:\(Int(weather.main.tempMin))º H:\(Int(weather.main.tempMax))º)",
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
            
            return PollutionInfo(items: items, quality: pollutionIndex[mainIndex]!)
        }
        return nil
    }
    
    func getWeatherForecastListInfo() -> WeatherForecastList? {
        var forecastList: WeatherForecastList? = nil
        
        // two formatters, one for the day and another for the hour of the day
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        
        var uniqueDTs: Set<String> = Set()
        
        if let forecastData = dataModel.weatherForecastData {
           
            // initialise and empty list
            forecastList = []
            
            var count = 0
            // get the list present in the model
            let forecastDataList = forecastData.list
            
            // loop through all the elements in the list
            while count < forecastDataList.count {
                // get the first weatherForecast data object
                var weatherData = forecastDataList[count]
                var lowTemp = 0
                var highTemp = 0
                // For that day, initialise an empty HourIconUrl array
                var hourIconUrlss : [HourIconUrl] = []
                // get the first day
                let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))
                uniqueDTs.insert(date)
                // get the hour of that day
                var hour = hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))
                
                // keep track of low and high temperatures
                lowTemp += Int(weatherData.main.tempMin)
                highTemp += Int(weatherData.main.tempMax)
                // add the initial hour to the array
                hourIconUrlss.append(HourIconUrl(hour: "\(Int(hour) ?? 0)H", url: URL(string: "https://openweathermap.org/img/wn/\(weatherData.weather[0].icon)@2x.png")!))
                
                // increment the counter
                count += 1
                
                // Loop until the 8th item(7th index) in the array and
                // do as above
                // This is to get all the forecast data for the 8 hours for
                // each day that we have in the forecast data returned from the
                // api
                for j in count..<(count+7) {
                    if j == forecastDataList.count {
                        break
                    }
                    weatherData = forecastDataList[j]
                    hour = hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))
                    lowTemp += Int(weatherData.main.tempMin)
                    highTemp += Int(weatherData.main.tempMax)
                    hourIconUrlss.append(HourIconUrl(hour: "\(Int(hour) ?? 0)H", url: URL(string: "https://openweathermap.org/img/wn/\(weatherData.weather[0].icon)@2x.png")!))
                }
                // increment count by 7
                count += 7
                
                if count == forecastDataList.count {
                    break
                }
                
                // append a WeatherForecastInfo with the day of the week,
                // and avergae low and high temperature
                // the list of hourIconUrls
                forecastList?.append(WeatherForecastInfo(dayOfWeek: uniqueDTs.count == 1 ? "Today" : date,
                                                         tempLowHigh: "(L: \(Int(lowTemp / hourIconUrlss.count))º H: \(Int(highTemp / hourIconUrlss.count))º)",
                                                        hourIconUrls: hourIconUrlss))
            }
        }
        
        return forecastList
    }
    
    func getPollutionForecastList() -> PollutionForecastList? {
        var forecastList: PollutionForecastList? = nil
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        
        var uniqueDTs: Set<String> = Set()
        
        if let forecastData = dataModel.pollutionForecastData {
            forecastList = []
            
            for pollutionData in forecastData.list {
                let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(pollutionData.dt)))
                if uniqueDTs.count < 5 && !uniqueDTs.contains(date) {
                    forecastList?.append(PollutionForecastInfo(day: date, index: pollutionIndex[pollutionData.main.aqi]!))
                    uniqueDTs.insert(date)
                }
                
                if uniqueDTs.count >= 5 {
                    break;
                }
            }
        }
        
        return forecastList
    }
    
    func getMapInfo() -> MapInfo? {
        var map = MapInfo(longitude: 0.0, latitude: 0.0)
        
        if let geoCode = dataModel.geocodeData {
            map.latitude = geoCode.first!.lat
            map.longitude = geoCode.first!.lon
        }
        
        return map
    }
    
    func getRegion() -> MKCoordinateRegion? {
        var region: MKCoordinateRegion? = nil
        
        if let geoCode = dataModel.geocodeData {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: geoCode.first!.lat, longitude: geoCode.first!.lon), latitudinalMeters: 5, longitudinalMeters: 5)
        }
        
        return region
    }
    
    private func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
}

extension WeatherViewModel {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(center: $0.coordinate,
                                        span: .init(latitudeDelta: 1, longitudeDelta: 1))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
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
