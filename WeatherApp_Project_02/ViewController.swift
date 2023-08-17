//
//  ViewController.swift
//  WeatherApp_Project_02
//
//  Created by Smera on 2023-08-01.
//

import UIKit
import CoreLocation
import MapKit
import Foundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    let locationManager = CLLocationManager()
    let locationDelegate = MyLocationDelegate()
    
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var farenheitButton: UIButton!
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var searchTextField: UISearchBar!
    var enteredLocation : String = ""
    var weatherCondition: String = ""
    var temp_c = " "
    var temp_f = " "
    var imageSet = false
    var c = 0
    var f = 0
    var weatherResponse: WeatherResponse?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = locationDelegate
        
        
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        
        locationManager.startUpdatingLocation()
        searchTextField.delegate = self

        if UserDefaults.standard.string(forKey: "API") == nil {
            UserDefaults.standard.set("e0c4b1cdfc844e66a38203457232207", forKey: "API_KEY")
        }
        
    }
    
    
    @IBAction func celsiusButtonTapped(_ sender: UIButton) {
        celsiusButton.backgroundColor = UIColor.systemBackground
        farenheitButton.backgroundColor = nil
        celsiusButton.setTitleColor(.white, for: .normal)
        c = 1
        f = 0
        // Update the weather condition before displaying temperature
        if let weatherCondition = weatherResponse?.current.condition.text {
            self.weatherCondition = weatherCondition
        }
        displayTemperature(temp_c: temp_c, temp_f: temp_f, weatherCondition: weatherCondition)
    }
    
    @IBAction func farenheitButtonTapped(_ sender: UIButton) {
        celsiusButton.backgroundColor = nil
        farenheitButton.backgroundColor = UIColor.systemBackground
        farenheitButton.setTitleColor(.white, for: .normal)
        c = 0
        f = 1
        // Update the weather condition before displaying temperature
        if let weatherCondition = weatherResponse?.current.condition.text {
            self.weatherCondition = weatherCondition
        }
        displayTemperature(temp_c: temp_c, temp_f: temp_f, weatherCondition: weatherCondition)
    }
    
    
    
//    // for passing data
//    struct CityWeather {
//        let iconName: String
//        let temperature: String
//        let cityName: String
//    }

    var searchedCities: [CityWeather] = []
 
    //
    
    struct Location: Codable {
        let name: String
        let region: String
        let country: String
        
    }
    
    struct WeatherCondition: Codable {
        let text: String
        let icon: String
        let code: Int
        
    }
    
    struct CurrentWeather: Codable {
        let last_updated_epoch: Int
        let last_updated: String
        let temp_c: Double
        let temp_f: Double
        let is_day: Int
        let condition: WeatherCondition
        
    }
    
    struct WeatherResponse: Codable {
        let location: Location
        let current: CurrentWeather
        
    }
    
    
    
    func retrievedCurrentData(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            let latitude = location.coordinate.latitude
            
            let longitude = location.coordinate.longitude
            
            print("LatLng: (\(latitude), \(longitude))")
            
        }
    }
    
    @IBAction func changeKeyTap(_ sender: Any) {
        let alertVC = UIAlertController(title: "", message: "New Key", preferredStyle: .alert)
        alertVC.addTextField()
        let cancelA = UIAlertAction(title: "Cancel", style: .default, handler: {_ in
            alertVC.dismiss(animated: true)
        })
        
        let saveA = UIAlertAction(title: "Save", style: .default, handler: {_ in
            if let key = alertVC.textFields?.first?.text{
                UserDefaults.standard.set(key, forKey: "KEY")
            }
        })
        
        alertVC.addAction(cancelA)
        alertVC.addAction(saveA)
        self.present(alertVC, animated: true, completion: nil)
      }
    
    
    func getWeather(for location: String, completion: @escaping (WeatherResponse?) -> Void) {
        let apiKey =  UserDefaults.standard.string(forKey: "KEY")
        let baseURL = "https://api.weatherapi.com/v1/current.json"
        let query = "?key=\(apiKey)&q=\(location)"
        let endpoint = "\(baseURL)\(query)"
        
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let urlSession = URLSession(configuration: .default)
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error!)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(weatherResponse)
            } catch {
                print(error)
                completion(nil)
            }
        }
        
        dataTask.resume()
    }
    
    
    
    
    
    
    func displayTemperature(temp_c: String, temp_f: String, weatherCondition: String) {
        DispatchQueue.main.async {
            self.tempLabel.text = self.c == 0 && self.f == 1 ? temp_f + " °F" : temp_c + " °C"
            if self.imageSet == false {
                
                self.weatherConditionLabel.text = weatherCondition
                if let symbolName = self.weatherConditionImages[weatherCondition] {
                    let config = UIImage.SymbolConfiguration(paletteColors: [.yellow, .blue])
                    self.weatherConditionImage.preferredSymbolConfiguration = config
                    self.weatherConditionImage.image = UIImage(systemName: symbolName)
                    self.imageSet = true
                } else {
                    
                    self.weatherConditionImage.image = UIImage(systemName: "questionmark.circle")
                    self.imageSet = true
                }
            }
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            enteredLocation = text
            locationText.text = text.uppercased()
            print("Search Weather for: \(text)")
            getWeather(for: enteredLocation) { weatherResponse in
                if let weatherData = weatherResponse?.current {
                    let cityName = weatherResponse?.location.name ?? "Unknown City"
                    let temperature = self.c == 1 ? String(weatherData.temp_c) : String(weatherData.temp_f)
                    let iconName = weatherData.condition.icon
                    self.searchedCities.append(CityWeather(iconName: iconName, temperature: temperature, cityName: cityName))
                    
                    self.temp_c = String(weatherData.temp_c)
                    self.temp_f = String(weatherData.temp_f)
                    
                    // Access and print the weather condition
                    
                    let weatherCondition = weatherData.condition.text
                    print("Weather Condition: \(weatherCondition)")
                    
                    self.displayTemperature(temp_c: self.temp_c, temp_f: self.temp_f, weatherCondition: weatherCondition)
                    
                    print("Temperature in Celsius: \(weatherData.temp_c) °C")
                    print("Temperature in Fahrenheit: \(weatherData.temp_f) °F")
                } else {
                    print("Error fetching weather data")
                }
            }
        } else {
            showAlert(title: "Error", message: "Please enter a location.")
        }
        
        searchBar.resignFirstResponder() // Hide the keyboard
    }

    
    
    @IBAction func findLocationTapped(_ sender: Any, forEvent event: UIEvent) {
        imageSet = false
        if let text = searchTextField.text, !text.isEmpty {
            enteredLocation = text
            locationText.text = text.uppercased()
            print("Search Weather for: \(text)")
            getWeather(for: enteredLocation) { weatherResponse in
                if let weatherData = weatherResponse?.current {
                    let cityName = weatherResponse?.location.name ?? "Unknown City"
                    let temperature = self.c == 1 ? String(weatherData.temp_c) : String(weatherData.temp_f)
                    let iconName = weatherData.condition.icon
                    self.searchedCities.append(CityWeather(iconName: iconName, temperature: temperature, cityName: cityName))
                    
                    self.temp_c = String(weatherData.temp_c)
                    self.temp_f = String(weatherData.temp_f)
                    
                    // Access and print the weather condition
                    
                    let weatherCondition = weatherData.condition.text
                    print("Weather Condition: \(weatherCondition)")
                    
                    self.displayTemperature(temp_c: self.temp_c, temp_f: self.temp_f, weatherCondition: weatherCondition)
                    
                    print("Temperature in Celsius: \(weatherData.temp_c) °C")
                    print("Temperature in Fahrenheit: \(weatherData.temp_f) °F")
                } else {
                    print("Error fetching weather data")
                }
            }
        } else {
            showAlert(title: "Error", message: "Please enter a location.")
        }
    }
    
    let weatherConditionImages: [String: String] = [
        "Sunny": "sun.max.fill",
        "Clear": "sun.max.fill",
        "Partly Cloudy": "cloud.sun.fill",
        "Partly cloudy": "cloud.sun.fill",
        "Cloudy": "cloud.fill",
        "Overcast": "cloud.sun.fill",
        "Rainy": "cloud.rain.fill",
        "Showers": "cloud.sun.rain",
        "Thunderstorms": "cloud.bolt.rain",
        "Snowy": "cloud.snow",
        "Foggy": "cloud.fog",
        "Windy": "wind",
        "Mist": "cloud.fog",
        "Patchy rain possible": "cloud.sun.rain",
        "Patchy snow possible": "cloud.snow",
        "Patchy sleet possible": "cloud.hail",
        "Patchy freezing drizzle possible": "cloud.drizzle.fill",
        "Thundery outbreaks possible": "cloud.bolt.rain",
        "Blowing snow": "snow",
        "Blizzard": "snow",
        "Fog": "cloud.fog",
        "Freezing fog": "cloud.fog.fill",
        "Patchy light drizzle": "cloud.drizzle.fill",
        "Light drizzle": "cloud.drizzle.fill",
        "Freezing drizzle": "cloud.drizzle.fill",
        "Heavy freezing drizzle": "cloud.drizzle.fill",
        "Patchy light rain": "cloud.rain.fill",
        "Light rain": "cloud.rain.fill",
        "Moderate rain at times": "cloud.rain.fill",
        "Moderate rain": "cloud.rain.fill",
        "Heavy rain at times": "cloud.rain.fill",
        "Heavy rain": "cloud.rain.fill",
        "Light freezing rain": "cloud.hail",
        "Moderate or heavy freezing rain": "cloud.hail",
        "Light sleet": "cloud.hail",
        "Moderate or heavy sleet": "cloud.hail",
        "Patchy light snow": "cloud.snow.fill",
        "Light snow": "cloud.snow.fill",
        "Patchy moderate snow": "cloud.snow.fill",
        "Moderate snow": "cloud.snow.fill",
        "Patchy heavy snow": "cloud.snow.fill",
        "Heavy snow": "cloud.snow.fill",
        "Ice pellets": "cloud.hail",
        "Light rain shower": "cloud.sun.rain",
        "Moderate or heavy rain shower": "cloud.sun.rain",
        "Torrential rain shower": "cloud.sun.rain",
        "Light sleet showers": "cloud.hail",
        "Moderate or heavy sleet showers": "cloud.hail",
        "Light snow showers": "cloud.snow.fill",
        "Moderate or heavy snow showers": "cloud.snow.fill",
        "Light showers of ice pellets": "cloud.hail",
        "Moderate or heavy showers of ice pellets": "cloud.hail",
        "Patchy light rain with thunder": "cloud.bolt.rain",
        "Moderate or heavy rain with thunder": "cloud.bolt.rain",
        "Patchy light snow with thunder": "cloud.bolt.snow",
        "Moderate or heavy snow with thunder": "cloud.bolt.snow"
    ]
    
    
    
    
    
    
    
    @IBAction func citiesTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "secondView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondView" {
            if let secondViewControllers = segue.destination as? SecondViewController {
                secondViewControllers.citiesWeatherArray = searchedCities
            }
        }
    }
    
    
    
    @IBAction func onGetLocationClicked(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        
        
        
        // retrievedCurrentData(locationManager, didUpdateLocations: locationManager.locations)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No location found")
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let latitudeString = String(latitude)
        let longitudeString = String(longitude)
        
        print("LatLng: (\(latitude), \(longitude))")
        
        let locationString = "\(latitude),\(longitude)"
        //        getWeather(for: locationString) { weatherResponse in
        //            // Process weather data if needed
        //        }
        //
        //
    }
    
    

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

class MyLocationDelegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got location")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}



/*
 
 func retrievedCurrentData(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

 if let location = locations.last {

 let latitude = location.coordinate.latitude

 let longitude = location.coordinate.longitude

 print("LatLng: (\(latitude), \(longitude))")

 }*/
 
