////
////  WeatherModel.swift
////  MetUCD
////
////  Created by Bori Akinola on 06/11/2023.
////
//
//import Foundation
//import SwiftUI
//
//struct WeatherModel: Codable {
//    
//    // All fields gotten from the OpenWeather API
//    // https://api.openweathermap.org/data/2.5/weather
//    
//    struct Response: Codable {
//        
//        private enum CodingKeys: String, CodingKey {
//            case main, wind
//            case clouds
//        }
//        private enum CloudCodingKeys: String, CodingKey {
//            case all
//        }
//        
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            main = try container.decode(MainInfo.self, forKey: .main)
//            wind = try container.decode(WindInfo.self, forKey: .wind)
//
//            // Extract "clouds.all" and map it to "cloudsAll"
//            let cloudContainer = try container.nestedContainer(keyedBy: CloudCodingKeys.self, forKey: .clouds)
//            clouds = CloudInfo(all: try cloudContainer.decode(Int.self, forKey: .all))
//        }
//        
//        init(main: MainInfo = MainInfo(temp: 0.0, feelsLike: 0.0, pressure: 0.0, humidity: 0.0),
//                     wind: WindInfo = WindInfo(speed: 0.0, direction: 0),
//             clouds: CloudInfo = CloudInfo(all: 0)) {
//            self.main = main
//            self.wind = wind
//            self.clouds = clouds
//        }
//    }
//    
//    var longitude: Double
//    var latitude: Double
//    private var baseURL = "https://api.openweathermap.org/"
//    var endpoint: String
//    var apiResponse: Response? = nil
//    
//    init(longitude: Double, latitude: Double) {
//        
//        self.longitude = longitude
//        self.latitude = latitude
//        self.endpoint = "/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=a217d4b7c0bd4440dd30d808358561fb"
//        
//        guard let url = URL(string: baseURL + endpoint) else {
//            print("Cannot create URL from given string")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
////        URLSession.shared.dataTask(with: request) { (data, response, error) in
////      
////            if let error = error {
////                print("Error: \(error)")
////                return
////            }
////
////            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
////                print("Invalid response")
////                return
////            }
////
////            if let data = data {
////                do {
////                    let result = try JSONDecoder().decode(Response.self, from: data)
////                    self.apiResponse = result
////                } catch {
////                    print("Error decoding data: \(error)")
////                }
////            }
////            
////        }
//        
//       
//        
//    }
//    
//    func printDetails() {
//        
//        if let apiResponse {
//            print("Temperature: " + "\(apiResponse.main.temp)")
//            print("Feels like: " + "\(apiResponse.main.feelsLike)")
////            print("Humidity: " + "\(self.apiResponse.main.humidity)")
////            print("Pressure: " + "\(self.apiResponse.main.pressure)")
////
////            print("Wind speed: " + "\(self.apiResponse.wind.speed)")
////            print("Wind direction: " + "\(self.apiResponse.wind.direction)")
//        }
//        }
//       
//    
//}
//
//
//
//
//
