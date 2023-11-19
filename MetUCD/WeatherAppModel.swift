//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Bori Akinola on 15/11/2023.
//

import Foundation

struct WeatherAppModel: Codable {
    
    
    
    
    // Mark:-
    
    struct GeocodeModel : Codable {
        
        struct Location: Codable {
            var name: String
            var localNames: [String: String]?
            var lat: Double
            var lon: Double
            var country: String
            var state: String?
        }
        
        let locations: [Location]
        
        static func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
            
            guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=Dublin,IE&limit=5&appid=a217d4b7c0bd4440dd30d808358561fb") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if !(200..<300).contains(httpResponse.statusCode) {
                        completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                        return
                    }
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }
                
                // Print the raw data received
                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "No data")")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode([Location].self, from: data)
                    print("Data decode correctly")
                    completion(.success(decodedData))
                } catch {
                    print("Data couldn't be decoded")
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
}
