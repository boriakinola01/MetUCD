//
//  ContentView.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import SwiftUI
import CoreLocation
import Charts

struct WeatherView: View {
    
    @Bindable var viewModel: WeatherViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SEARCH")) {
                    TextField("Enter location e.g Dublin, IE ", text: $viewModel.location)
                        .onSubmit {
                            viewModel.fetchData()
                        }.disableAutocorrection(true)
                }
                
                if let data = viewModel.geoInfo {
                    GeoSection(model: data)
                }
                
                if let data = viewModel.weatherInfo {
                    WeatherSection(model: data)
                }
                
                if let data = viewModel.pollutionInfo {
                    PollutionSection(model: data)
                }
                
                if let data = viewModel.weatherForecastListInfo {
                    WeatherForecastSection(model: data)
                }
                
                if let data = viewModel.pollutionForecastListInfo {
                    PollutionForecastSection(model: data)
                }
            }
        }
    }
    
    struct GeoSection : View {
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
    
    struct WeatherSection : View {
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
    
    struct WeatherForecastSection : View {
        var model = WeatherViewModel.WeatherForecastList()
        var body: some View {
            Section(header: Text("5 day forecast")) {
                ForEach(model, id: \.self) { forecast in
                    HStack {
                        Text("\(forecast.dayOfWeek)")
                            .tint(.blue)
                            .frame(width: 50)
                        Spacer().frame(width: 120)
                        HStack {
                            Image(systemName: "thermometer.medium").opacity(0.5)
                            Text("\(forecast.tempLowHigh)").opacity(0.5)
                        }
                    }
                }
            }
        }
    }
    
    struct PollutionForecastSection : View {
        var model = WeatherViewModel.PollutionForecastList()
        var body: some View {
            Section(header: Text("AIR POLLUTION INDEX FORECAST")) {
                Chart {
                    ForEach(model) { forecast in
                        LineMark(x: .value("Day", forecast.day), y: .value("Index", forecast.index))
                            .interpolationMethod(.stepStart)
                    }
                }
                .frame(height: 200)
//                .chartYAxis(
//                    AxisMarks(position: .leading)
//                )
//                .chartYScale(
//                    domain: ["Very Poor", "Poor", "Moderate", "Fair", "Good"]
//                )
                
            }
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
