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
    @IBOutlet private weak var weatherLabel: UILabel!
    @IBOutlet private weak var minimumTemp: UILabel!
    @IBOutlet private weak var maxTemp: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var weatherImageView: UIImageView!
    @IBOutlet private weak var weatherView: UIView!
    @IBOutlet private weak var editDiaryTextView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let diaryData = DiaryData()
    private let locationManager = LocationManager()
    private let weatherManager = WeatherManager()
    
    var date = Date() // showcalendarで選択された日付が渡される
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    // もし、位置情報の許可がされなければshowAlertが呼ばれる。
    override func viewDidAppear(_ animated: Bool) {
        if !locationManager.isPermission() {
            showAlert()
        }
        if Calendar.current.isDateInToday(date) {
            getWeatherInfo()
        }
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        diaryData.deleteData(selectDate: date)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapRecognizer(_ sender: Any) {
        view.endEditing(true)
    }
    
    private func setupView() {
        navigationItem.title = date.string(format: "yyyy/MM/dd")
        diaryData.allData() // diaryData.allDataを呼びrealmの情報をコンソールに表示している
        weatherView.isHidden = !Calendar.current.isDateInToday(date)
        locationManager.setupLocationManager() // locationManagerのsetupLocationManagerを呼ぶ
        editDiaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        editDiaryTextView.layer.cornerRadius = 10
        editDiaryTextView.sizeToFit()
        weatherView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        editDiaryTextView.text = diaryData.getEventData(selectDate: date) // 保存された日記をeditDiaryTextViewに表示させる
    }
    
    private func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    private func getWeatherInfo() {
        weatherManager.getWeatherDate(latitude: locationManager.latitudeNow, longitude: locationManager.longitudeNow) { result in
            print("リザルト:large_red_square:\(result)")
            switch result {
            case .success(let weatherData):
                switch weatherData.descriptionWeather {
                case "Clouds":
                    self.weatherLabel.text = "曇り"
                case "Rain":
                    self.weatherLabel.text = "雨"
                case "Snow":
                    self.weatherLabel.text = "雪"
                case "Mist":
                    self.weatherLabel.text = "霧"
                default:
                    self.weatherLabel.text = "晴れ"
                }
                self.weatherImageView.image = UIImage(named: weatherData.descriptionWeather)
                self.minimumTemp.text = "\(weatherData.tempMin)°C"
                self.maxTemp.text = "\(weatherData.tempMax)°C"
                self.humidityLabel.text = "湿度\(weatherData.humidity)%"
            case .failure(let failure):
                print("天気情報取得エラー：\(failure)")
                self.weatherLabel.text = "天気情報を取得できませんでした"
            }
        }
    }
    
    private func saveDate() {
        if editDiaryTextView.text == "" { return } // editDiaryTextViewに文字がなければ以下の処理は実行しない。
        guard let editDiaryText = editDiaryTextView.text else { return }
        
        if diaryData.getEventData(selectDate: date) == "" {
            diaryData.saveData(date: date.string(format: "yyyy/MM/dd"), event: editDiaryText)
        } else {
            diaryData.updateData(selectDate: date, event: editDiaryText)
        }
        diaryData.allData()
    }
}
