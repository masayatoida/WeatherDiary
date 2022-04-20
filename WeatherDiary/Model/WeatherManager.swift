//
//  WeatherManager.swift
//  WeatherDiary
//
//  Created by 戸井田莉江 on 2022/04/08.
//

import Foundation
import SwiftyJSON
import Alamofire

struct WeatherManager {
    func getWeatherDate(latitude: String, longitude: String, handler: @escaping (Result<String, Error>) -> Void) {
        let myAPIKey = "394956789e3684cbaee8183ee142599a"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(myAPIKey)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                print(json)
                guard let descriptionWeather = json["weather"][0]["main"].string else { return }
                handler(.success(descriptionWeather))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
