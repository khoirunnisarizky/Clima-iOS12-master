//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
//how to know poistion / location by GPS Wifi etc of the device
import Alamofire
//make a http request by using application program interface
import SwiftyJSON
//import the protocol that we want  to adopt
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    //weatherview controller subklas dr dua kelas di kanannya
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "951d895d686438443960a416697a6fe9"
    
    //original API Key e72ca729af228beabd5d20e3b7749713
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    //Create weather data model object
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self //untuk transform dari core location ke kelas UIView Controller karena sudah diset dg delegation
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //asynchronous method for getting GPS location - works in background for the best user experience -> send the data location to the UIViewController
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    // mark ini memudahkan kita kalo code nya panjang bisa diklik weather view controller di atas terus mencet aja
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters: [String:String]) {
        //asynchronized method
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Succes! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                //Java Script Object Notation
                self.updateWeatherData(json: weatherJSON)
                //print(weatherJSON) untuk dapetin datanya dari api
                
            } else { //kalo koneksinya ilang gitu biasanya
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
                
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        //optional binding is saver that force unwrapping using ! or ??
        if let tempResult = json["main"]["temp"].double {//using library swiftyJSON -- untuk update data weathernya gunakan weather data model : .double untuk convert data json ke double di tempResult
        
        weatherDataModel.temperature = Int(tempResult - 273.15) //force unwrapping using ! in temp result is danger if there is any typo in API key so using optional binding
        //icon V untuk object dan icon C untuk kelas
        
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"]["0"]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIWithWeatherData()
            
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    // what to do after we get the location data (dapat didefinisikan lokasinya) from updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //cllocation untuk accuracy lokasi
        let location = locations[locations.count - 1] //untuk dapetin nilai terakhir dari arraynya locations
        //make sure they are valid caranya
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation() //udah dapet hasil yang valid
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            //parameter untuk menjalankan weather maps API nya : ada 3 parameter utk API call
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            //then  do networking between our app and openweather map by http request
            //to make a http request using pod : alamofire
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
            
            
        }
        
    }
    
    
    //Write the didFailWithError method here:
    //kalo gabisa dapet data location karena ga ada koneksi etc etc maka ini yg dilakukan
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
   func userEnteredANewCityName(city: String) {
    
    let params : [String : String] = ["q" : city, "appid" : APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
    
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    
    
    
}


