#  METUCD Weather Project - Part Two

Note:

There are some things currently not working:

- The button at the top right doesn't centre the map on the users location
- Tapping on the map screen doesn't do what it's meant to do
- There is a bug in passing the location from the view to the viewmodel and passing it on to the model to get the weather information.



## Changes made from part one:

### ViewModel

The ViewModel now conforms to the NSObject and CLLocationManagerDelegate protocols

I have an initialiser that sets teh locationManager delegate and calls a setup function

```
override init() {
    super.init()
    
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    self.setup()
}
```

The `setup` function just handles the location permissions for the locaiton manager:

```
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
```

The viewmodel also has an `extension` that implements some locationManager functions

- One that updates that triggers when the users location changes 
```
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locations.last.map {
        region = MKCoordinateRegion(center: $0.coordinate,
                                    span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
}
```
This sets the region centre to the current location

- One that sends a message when the location manager fails with an error
```
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Something went wrong: \(error)")
}
```
- One that handles when the users changes the permission authorisation
```
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard .authorizedWhenInUse == manager.authorizationStatus else { return }
    locationManager.requestLocation()
}
```

#### A few other varibles added:

A map info variable that contains information about the location where the map was tapped on. It sends this location into the map.

The mapInfo is declared as such:
```
var mapInfo: MapInfo? {
    get {return getMapInfo()}
    
    set {}
    
}
```

A region variable that should update the MKCoordinateRegion of the map through the MapCameraPosition

```
var region: MKCoordinateRegion? {
    get {return getRegion()}
    set {}
}
    
```

There is a new struct HourIconUrls that help display the weatherforecast icons and the hour of the day
```
struct HourIconUrl: Hashable {
    var hour: String
    var url : URL
}
```
The `getWeatherForecastListInfo` function has been refactored to take into account the image icons for each of the hours of the weather forecast.
How it works is explained in the comments

```
    func getWeatherForecastListInfo() -> WeatherForecastList? {
        var forecastList: WeatherForecastList? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        
        var uniqueDTs: Set<String> = Set()
        
        if let forecastData = dataModel.weatherForecastData {
           
            forecastList = []
            
            var count = 0
            let forecastDataList = forecastData.list
            
            while count < forecastDataList.count {
                var weatherData = forecastDataList[count]
                var lowTemp = 0
                var highTemp = 0
                var hourIconUrlss : [HourIconUrl] = []
                let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))
                uniqueDTs.insert(date)
                
                var hour = hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weatherData.dt)))
                lowTemp += Int(weatherData.main.tempMin)
                highTemp += Int(weatherData.main.tempMax)
                hourIconUrlss.append(HourIconUrl(hour: "\(Int(hour) ?? 0)H", url: URL(string: "https://openweathermap.org/img/wn/\(weatherData.weather[0].icon)@2x.png")!))
                
                count += 1
                
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
                count += 7
                
                if count == forecastDataList.count {
                    break
                }
                
                forecastList?.append(WeatherForecastInfo(dayOfWeek: uniqueDTs.count == 1 ? "Today" : date,
                                                         tempLowHigh: "(L: \(Int(lowTemp / hourIconUrlss.count))º H: \(Int(highTemp / hourIconUrlss.count))º)",
                                                        hourIconUrls: hourIconUrlss))
            }
        }
        
        return forecastList
    }
```
The `WeahterForecastInfo` was also updated to include the `hourIconUrls`
```
    struct WeatherForecastInfo: Hashable {
        var dayOfWeek: String
        var tempLowHigh: String
        var hourIconUrls: [HourIconUrl]
    }
```

### View

The view is Mainly a Map.

The map has an <b>overlay</b> which view that pops up when a location on the map is tapped, or a location is entered in the search bar.

```
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
            
            :
            :
            :
            :
            .background(
            Color(.cyan).opacity(0.8),
            in: RoundedRectangle(cornerRadius: 10))
        }.frame(width: 1000)
            
    }
}
```

When this preview is tapped, the weather information shows up as a <b>sheet</b>. This behaviour is controlled my the boolean variable <b>showWeatherFull</b>

The weather forecast information in the view is more or less the same as Part One, except for the weather forecast view. This secttion now shows icons gotten form the OpenWeatherMap API to display icons that represent the weather information along with the hour forecast.
If the image isn't loaded, there is a placeholder `hourglass` image that displays first


When a location on the map is tapped, the coordinates are passed into the viewmodel adn the region of the mapcamerapositino is updated
```
    .onTapGesture(perform: { screenCoord in
        let pinLocation = reader.convert(screenCoord, from: .local)
        viewModel.mapInfo?.latitude = pinLocation!.latitude
        viewModel.mapInfo?.longitude = pinLocation!.longitude
        viewModel.fetchData()
        if let region = viewModel.region {
            mapCameraPosition = MapCameraPosition.region(region)
        }
        
        showWeatherPopup = true
```

There is a button at the top of the map that should centre the map position on the current user location

