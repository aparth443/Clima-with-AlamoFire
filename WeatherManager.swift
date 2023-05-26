//
//  WeatherManager.swift
//  Clima
//
//  Created by cumulations on 16/05/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire


protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=086f14376a650140bf5997fce00f88ff&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //1. Create a URL
        
        AF.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
            .response { response in
                switch response.result{
                case .success(let data):
                    do{
                        if let weather = parseJSON(data!){
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                case .failure(let error):
                    delegate?.didFailWithError(error)
                    return
                }
            }
    }
    
    func parseJSON(_ weatherData: Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherId = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: weatherId, name: name, temp: temp)
            return weather
            
        }catch{
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
    
    
}
