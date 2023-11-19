//
//  ContentView.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import SwiftUI
import CoreLocation

@Observable
class ViewModel {
    var location: String = ""
    
    // MARK: data model
    private var dataModel = WeatherAppModel()
    
    func fetchData() {
        Task {
            await dataModel.fetch(for: location)
        }
    }

}

struct ContentView: View {
    
    @State private var showSections = false
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SEARCH")) {
                    TextField("Enter location e.g Dublin, IE ", text: $viewModel.location)
                        .onSubmit {
                            viewModel.fetchData()
                            showSections = true
                        }
                }
                
                WeatherDetailsView()
                
            }
        }
    }
    
    struct WeatherDetailsView : View {
        
        let pollution: WeatherAppModel.PollutionData = WeatherAppModel.PollutionData(co: 110.3, no: 0.22, no2: 0.64, o3: 0.33, pm10: 0.0, pm2_5: 0.32, so2: 17.2, nh3: 0.0)
        
        let polluteMirror = Mirror(reflecting: WeatherAppModel.PollutionData(co: 110.3, no: 0.22, no2: 0.64, o3: 0.33, pm10: 0.0, pm2_5: 0.32, so2: 17.2, nh3: 0.0))
        
        
        
        var body: some View {
            
            Section(header: Text("GEO INFO")) {
                Label(
                    title: { Text("19.23.23 N, 22.45.66 W") },
                    icon: { Image(systemName: "location.fill") }
                )
                HStack {
                    Label(
                        title: {
                            HStack(spacing: 0) {
                                Text("08:03")
                                Text("(04:03)").opacity(0.5)
                            }
                        },
                        icon: { Image(systemName: "sunrise") }
                    )
                    Label(
                        title: {
                            HStack(spacing: 0) {
                            Text("08:03")
                            Text("(04:03)").opacity(0.5)
                        }},
                        icon: { Image(systemName: "sunset") }
                    )
                }
                Label(
                    title: { Text("19.23.23 N, 22.45.66 W") },
                    icon: { Image(systemName: "clock.arrow.2.circlepath") }
                )
                
            }
            
            Section(header: Text("Weather: Few Clouds")) {
                HStack {
                    Label(
                        title: {
                            HStack {
                                Text("9º")
                                Text("(L:6º H:17º)").opacity(0.5)
                            }
                            
                        },
                        icon: { Image(systemName: "thermometer.medium") }
                    )
                    Label(
                        title: { Text("Feels 9º") },
                        icon: { Image(systemName: "thermometer.variable.and.figure") }
                    )
                }
                
                
                Label(
                    title: { Text("13% Coverage") },
                    icon: { Image(systemName: "cloud") }
                )
                
                Label(
                    title: { Text("4.8 km/h, dir: 96º") },
                    icon: { Image(systemName: "wind") }
                )
                HStack {
                    Label(
                        title: { Text("50%") },
                        icon: { Image(systemName: "humidity") }
                    )
                    Label(
                        title: { Text("1020 hPa") },
                        icon: { Image(systemName: "gauge.with.dots.needle.bottom.50percent") }
                    )
                }
               
            }
            
            Section(header: Text("Air quality: Good")) {
                
            }
            
            Section(header: Text("5 day forecast")) {
                
            }
            
            
        }
        
    }
    
//    func searchButton() {
//        print(location)
//        
//        let model = WeatherAppModel(locationName: location)
//        
//    }
}

#Preview {
    ContentView()
}
