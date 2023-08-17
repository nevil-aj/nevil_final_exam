//
//  SecondViewController.swift
//  WeatherApp_Project_02
//
//  Created by Smera on 2023-08-04.
//


//
//import UIKit
//
//class SecondViewController: UIViewController {
//    @IBOutlet weak var cityWeatherLabel: UILabel!
//
//    var citiesWeatherArray: [CityWeather] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
       
        import UIKit

        class SecondViewController: UIViewController {
            @IBOutlet weak var cityWeatherLabel: UILabel!
            
            var citiesWeatherArray: [CityWeather] = []
            
            override func viewDidLoad() {
                super.viewDidLoad()
                print(citiesWeatherArray)
                var detailsText = ""
                for cityWeather in citiesWeatherArray {
                    detailsText += "City: \(cityWeather.cityName)\nTemperature: \(cityWeather.temperature)°\n\n--------------------------------------------"
                }
                
                cityWeatherLabel.text = detailsText
                cityWeatherLabel.numberOfLines = 0
                cityWeatherLabel.lineBreakMode = .byWordWrapping
            }
            
            @IBAction func goBackButtonTapped(_ sender: UIButton) {
                performSegue(withIdentifier: "goBack", sender: nil)
            }
        }
