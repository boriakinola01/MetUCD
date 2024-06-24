//
//  ContentView.swift
//  MetUCD
//
//  Created by Bori Akinola on 06/11/2023.
//

import SwiftUI
import CoreLocation
import Charts
import MapKit
import SDWebImageSwiftUI

struct WeatherAppView: View {
    
    @Bindable var viewModel: WeatherViewModel
    
    var position: MapCameraPosition = .automatic
    @State var showWeatherPopup = false
    @State var showWeatherFull = false
    @State var userCurrentLocation = true
    @State var region = MKCoordinateRegion()
    @State var mapCameraPosition = MapCameraPosition.automatic
    
    var body: some View {
        ZStack {
            MapReader { reader in
                Map(position: $mapCameraPosition) {
                    if let userLocationCoord = viewModel.locationManager.location?.coordinate {
                        Marker("", systemImage: "location.viewfinder",
                               coordinate: userLocationCoord)
                    }
                    
                    if let enteredLocationCoord = viewModel.mapInfo, let weather = viewModel.weatherInfo {
                        Marker("\(weather.temperature)", coordinate: CLLocationCoordinate2D(latitude: enteredLocationCoord.latitude, longitude: enteredLocationCoord.longitude))
                    }
                    
                }
                .ignoresSafeArea()
                .onAppear{
                    viewModel.locationManager.requestWhenInUseAuthorization()
                    viewModel.fetchData()
                }
                // Get the map location when the map is pressed
                .onTapGesture(perform: { screenCoord in
                    let pinLocation = reader.convert(screenCoord, from: .local)
                    viewModel.mapInfo?.latitude = pinLocation!.latitude
                    viewModel.mapInfo?.longitude = pinLocation!.longitude
                    viewModel.fetchData()
                    if let region = viewModel.region {
                        mapCameraPosition = MapCameraPosition.region(region)
                    }
                    
                    showWeatherPopup = true
                })
                .safeAreaInset(edge: .top){
                    HStack {
                        Spacer()
                        Button(action: {userCurrentLocation = true}, label: {
                            Image(systemName: "location.circle")
                                .font(Font.system(size: 40, design: .default))
                        })
                        Spacer()
                        Section {
                            TextField("Enter location e.g Dublin, IE ", text: $viewModel.location, onEditingChanged:{ _ in showWeatherPopup = false})
                                .onSubmit {
                                    userCurrentLocation = false
                                    viewModel.fetchData()
                                    showWeatherPopup = true
                                }.disableAutocorrection(true)
                                .background{
                                    Color(.gray).opacity(0.2)
                                }
                                .font(Font.system(size: 25, design: .default))
                                .cornerRadius(5.0)
                                .frame(height: 50)
                            }
                        Spacer()
                    }
                }.overlay(content: {
                    if showWeatherPopup {
                        if let data = viewModel.weatherInfo {
                            weatherPreview(model: data, location: viewModel.location).onTapGesture(perform: {
                                showWeatherFull = true
                            })
                        }
                    }
                })
                .sheet(isPresented: $showWeatherFull) {
                    NavigationView {
                        Form {
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
                }.onMapCameraChange {
                    showWeatherPopup = false
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
                                    HStack(spacing: 0) {
                                        Spacer()
                                        Text("\(item.element.key):")
                                            .foregroundStyle(.blue)
                                        Text("\(String(format: "%.2f", item.element.value))")
                                        Spacer()
                                    }.frame(maxWidth: .infinity, alignment: .leading)
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
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(forecast.dayOfWeek)")
                                .foregroundStyle(.blue)
                                .frame(width: 50)
                            Spacer().frame(width: 150)
                            HStack {
                                Image(systemName: "thermometer.medium").opacity(0.5)
                                Text("\(forecast.tempLowHigh)").opacity(0.5)
                            }
                        }
                        HStack {
                            ForEach(forecast.hourIconUrls, id: \.self) { hourIconUrl in
                                VStack(spacing: 0){
                                    Text("\(hourIconUrl.hour)")
                                    WebImage(url: hourIconUrl.url)
                                        .resizable()
                                        .placeholder{
                                            Image(systemName: "hourglass")
                                        }
                                        .background(Color(.gray).opacity(0.7),
                                                    in: RoundedRectangle(cornerRadius: 10))
                                        .aspectRatio(contentMode: .fit)
                                        
                                }.frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: true)
                            }
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
    
    func convertTapToCoordinate(viewPoint: CGSize) -> CLLocationCoordinate2D {
        let map = MKMapView()
        let point = CGPoint(x: viewPoint.width / 2, y: viewPoint.height / 2) // Center point for example
        let coordinate = map.convert(point, toCoordinateFrom: map)
        
        return coordinate
    }

}

struct weatherPreview: View {
    var model: WeatherViewModel.WeatherInfo
    var location: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack{
                Spacer()
            }
            VStack(spacing: 20){
                Text("\(location)")
                    .bold()
                    .font(Font.system(size: 30, design: .default))
                HStack {
                    Image(systemName: "thermometer").foregroundStyle(.pink).font(Font.system(size: 30, design: .default))
                    Text("\(model.temperature)").font(Font.system(size: 50, design: .default))
                    
                }.foregroundStyle(.pink).opacity(0.8)
                VStack {
                    Text("\(model.description)")
                    Text("\(model.tempLowHigh)").opacity(0.5)
                }.font(Font.system(size: 25, design: .default))
            }
            .frame(maxWidth: 200,
                   alignment: .bottom)
            .background(
            Color(.cyan).opacity(0.8),
            in: RoundedRectangle(cornerRadius: 10))
        }.frame(width: 1000)
            
    }
}

struct mapPreview: View {
    var body: some View {
        ZStack {
            MapReader { reader in
                Map()
                .onTapGesture(perform: { screenCoord in
                    let pinLocation = reader.convert(screenCoord, from: .local)
                    print(pinLocation!)
                })
            }
        }
        
    }
}


#Preview {
//    mapPreview()
    WeatherAppView(viewModel: WeatherViewModel())
}
