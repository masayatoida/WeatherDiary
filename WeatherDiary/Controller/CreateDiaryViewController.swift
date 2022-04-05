//
//  CreateDiaryViewController.swift
//  WeatherDiary
//
//  Created by 戸井田莉江 on 2022/02/28.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire


class CreateDiaryViewController: UIViewController {
    
    @IBOutlet private weak var eventTextfield: UITextField!
    @IBOutlet weak var weatherLabel: UILabel!
    
    var locationManager: CLLocationManager!
    // 緯度
    var latitudeNow: String = ""
    // 経度
    var longitudeNow: String = ""
    var date = Date()
    private let diaryData = DiaryData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let df =  DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        navigationItem.title = df.string(from: date)
        diaryData.allData()
        setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let manager = CLLocationManager()
        if manager.authorizationStatus == .denied {
            showAlert()
            return
        }
        getWeatherDate(latitude: latitudeNow, longitude: longitudeNow)
        print(latitudeNow)
        print(longitudeNow)
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
    }
    
    @IBAction func getLocationInfo(_ sender: UIButton) {
        setupLocationManager()
    }
    
    private func saveDate() {
        let df =  DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        diaryData.saveData(date: df.string(from: date), event: eventTextfield.text ?? "")
        diaryData.allData()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        // 位置情報取得許可ダイアログの表示
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        // マネージャの設定
        let manager = CLLocationManager()
        // ステータスごとの処理
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.delegate = self
            // 位置情報取得を開始
            locationManager.startUpdatingLocation()
        }
    }
    /// アラートを表示する
    func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle:  UIAlertController.Style.alert
        )
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        // UIAlertController に Action を追加
        alert.addAction(defaultAction)
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    private func getWeatherDate(latitude: String, longitude: String) {
        // TODO: - リリース前に自分用のAPIキーを取得する
        let myAPIKey = "55b317379a06a94f5198e9c297ff0b0e"
        let text = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(myAPIKey)"
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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

extension CreateDiaryViewController: CLLocationManagerDelegate {
    
    /// 位置情報が更新された際、位置情報を格納する
    /// - Parameters:
    ///   - manager: ロケーションマネージャ
    ///   - locations: 位置情報
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        // 位置情報を格納する
        self.latitudeNow = String(latitude!)
        self.longitudeNow = String(longitude!)
    }
}
