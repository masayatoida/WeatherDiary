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
    @IBOutlet private weak var weatherView: UIView!
    @IBOutlet private weak var editDiaryTextView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let diaryData = DiaryData()
    private let locationManager = LocationManager()
    private let weatherManager = WeatherManager()
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !locationManager.isPermission() {
            showAlert()
        }
        getWeatherInfo()
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    
    private func setupView() {
        navigationItem.title = date.string(format: "yyyy/MM/dd")
        diaryData.allData()
        locationManager.setupLocationManager()
        editDiaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        editDiaryTextView.layer.cornerRadius = 10
        editDiaryTextView.sizeToFit()
        weatherView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        editDiaryTextView.text = diaryData.getEventData(selectDate: date)
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
        let calendar = Calendar(identifier: .gregorian)
        if calendar.isDateInToday(date) {
            weatherManager.getWeatherDate(latitude: locationManager.latitudeNow, longitude: locationManager.longitudeNow) { result in
                switch result {
                case .success(let descriptionWeather):
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
                case .failure(let failure):
#warning("エラー処理を記述")
                    break
                }
            }
        }
    }
    
    private func saveDate() {
        if editDiaryTextView.text == "" { return }
        if diaryData.getEventData(selectDate: date) == "" {
            diaryData.saveData(date: date.string(format: "yyyy/MM/dd"), event: editDiaryTextView.text ?? "")
        } else {
            diaryData.updateData(selectDate: date, event: editDiaryTextView.text)
        }
        diaryData.allData()
    }
}
