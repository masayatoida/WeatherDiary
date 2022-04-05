//
// CreateDiaryViewController.swift
// WeatherDiary
//
// Created by 戸井田莉江 on 2022/02/28.
//

import UIKit
import SwiftyJSON
import Alamofire

class CreateDiaryViewController: UIViewController {
    @IBOutlet private weak var eventTextfield: UITextField!
    @IBOutlet private weak var weatherLabel: UILabel!
    
    private let diaryData = DiaryData()
    private let locationManager = LocationManager()
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        navigationItem.title = df.string(from: date)
        diaryData.allData()
        locationManager.setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !locationManager.isPermission() {
            showAlert()
        }
        let calendar = Calendar(identifier: .gregorian)
        if calendar.isDateInToday(date) {
            getWeatherDate(latitude: locationManager.latitudeNow, longitude: locationManager.longitudeNow)
        }
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
    }
    
    private func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    private func saveDate() {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        diaryData.saveData(date: df.string(from: date), event: eventTextfield.text ?? "")
        diaryData.allData()
    }
    
    private func getWeatherDate(latitude: String, longitude: String) {
        // TODO: - リリース前に自分用のAPIキーを取得する
        let myAPIKey = "55b317379a06a94f5198e9c297ff0b0e"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(myAPIKey)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                print(json)
                guard let descriptionWeather = json["weather"][0]["main"].string else { return }
                switch descriptionWeather {
                case "Clouds":
                    self.weatherLabel.text = "曇り"
                case "Rain":
                    self.weatherLabel.text = "雨"
                case "Snow":
                    self.weatherLabel.text = "雪"
                default:
                    self.weatherLabel.text = "晴れ"
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
