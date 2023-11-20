//
//  ContentView.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    
    @Bindable var viewModel: WeatherViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SEARCH")) {
                    TextField("Enter location e.g Dublin, IE ", text: $viewModel.location)
                        .onSubmit {
                            viewModel.fetchData()
                        }
                }
                
                if let data = viewModel.geoInfo {
                    geoSection(model: data)
                }
                
                if let data = viewModel.weatherInfo {
                    weatherSection(model: data)
                }
                
                if let data = viewModel.pollutionInfo {
                    PollutionSection(model: data)
                }
            }
        }
    }
    
    struct geoSection : View {
        var model: WeatherViewModel.GeoInfo
        var body: some View {
            Section(header: Text("GEO INFO")) {
                Label(
                    title: { Text("\(model.coordinates)") },
                    icon: { Image(systemName: "location.fill") }
                )
                HStack {
                    Label(
                        title: {
                            HStack(spacing: 0) {
                                Text("\(model.sunrise)")
                                Text("(04:03)").opacity(0.5)
                            }
                        },
                        icon: { Image(systemName: "sunrise") }
                    )
                    Label(
                        title: {
                            HStack(spacing: 0) {
                                Text("\(model.sunset)")
                            Text("(04:03)").opacity(0.5)
                        }},
                        icon: { Image(systemName: "sunset") }
                    )
                }
                Label(
                    title: { Text("\(model.timeDifference)") },
                    icon: { Image(systemName: "clock.arrow.2.circlepath") }
                )
                
            }
        }
    }
    
    struct weatherSection : View {
        var model: WeatherViewModel.WeatherInfo
        var body: some View {
            
            Section(header: Text("Weather: \(model.description)")) {
                
                HStack {
                    Label(
                        title: {
                            HStack {
                                Text("\(model.temperature)")
                                Text("\(model.tempLowHigh)").opacity(0.5)
                            }
                            
                        },
                        icon: { Image(systemName: "thermometer.medium") }
                    )
                    Label(
                        title: { Text("\(model.tempFeels)") },
                        icon: { Image(systemName: "thermometer.variable.and.figure") }
                    )
                }
                
                
                Label(
                    title: { Text("\(model.cloudCoverage)") },
                    icon: { Image(systemName: "cloud") }
                )
                
                Label(
                    title: { Text("\(model.windSpeedDirection)") },
                    icon: { Image(systemName: "wind") }
                )
                HStack {
                    Label(
                        title: { Text("\(model.humidity)") },
                        icon: { Image(systemName: "humidity") }
                    )
                    Label(
                        title: { Text("\(model.pressure)") },
                        icon: { Image(systemName: "gauge.with.dots.needle.bottom.50percent") }
                    )
                }
               
            }
        }
    }
    
    struct PollutionSection: View {
        var model: WeatherViewModel.PollutionInfo
        var body: some View {
            Section(header: Text("Air quality: \(model.quality)")) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<model.items.count / 2, id: \.self) { rowIndex in
                        HStack(spacing:30) {
                            ForEach(0..<2, id: \.self) { columnIndex in
                                if let item = model.items.enumerated().first(where: {$0.offset == rowIndex * 2 + columnIndex} ) {
                                    Text("\(item.element.key): \(String(format: "%.2f", item.element.value))")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Spacer()
                                }
                            }
                        }
                        
                    }
                   
                }
            }
        }
    }
    
    struct ForecastSection : View {
        
        var body: some View {
            
            Section(header: Text("5 day forecast")) {
                
            }
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
