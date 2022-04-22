//
// WeatherManager.swift
// WeatherDiary
//
// Created by 戸井田莉江 on 2022/04/08.
//

import Foundation
import SwiftyJSON
import Alamofire

struct WeatherData {
    var descriptionWeather = ""
    var tempMin = ""
    var tempMax = ""
    var humidity = ""
}

struct WeatherManager {
    func getWeatherDate(latitude: String, longitude: String, handler: @escaping (Result<WeatherData, Error>) -> Void) {
        let myAPIKey = "394956789e3684cbaee8183ee142599a"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(myAPIKey)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                print(json)
                
                guard let descriptionWeather = json["weather"][0]["main"].string,
                      let tempMin = json["main"]["temp_min"].number,
                      let tempMax = json["main"]["temp_max"].number,
                      let humidity = json["main"]["humidity"].number
                else { return }
                
                var weatherData = WeatherData()
                weatherData.descriptionWeather = descriptionWeather
                weatherData.tempMin = "\(Int(truncating: tempMin))"
                weatherData.tempMax = "\(Int(truncating: tempMax))"
                weatherData.humidity = "\(Int(truncating: humidity))"
                
                handler(.success(weatherData))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
