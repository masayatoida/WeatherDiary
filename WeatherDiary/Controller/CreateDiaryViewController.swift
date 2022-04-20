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
    @IBOutlet private weak var rainyPercent: UILabel!
    @IBOutlet private weak var weatherIcon: UIImageView!
    @IBOutlet private weak var weatherView: UIView!
    @IBOutlet private weak var editDiaryTextView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let diaryData = DiaryData()
    private let locationManager = LocationManager()
    private let weatherManager = WeatherManager()
    
    var date = Date()//showcalendarで選択された日付がわたされる？？
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        weatherView.isHidden = Calendar.current.isDateInToday(date) ? false : true
        //今日かどうか判定する。今日ならばisHiddenがfalseとなり表示される。今日ではないならisHiddenはtrueで非表示となる
    }
    //もし、位置情報の許可がされなければshowAlertが呼ばれる。viewDidAppearにした理由？？ワンテンポ間があったほうがいいから？
    override func viewDidAppear(_ animated: Bool) {
        if !locationManager.isPermission() {
            showAlert()
        }
        //今日ならば天気情報を取得する
        if Calendar.current.isDateInToday(date) {
            getWeatherInfo()
        }
    }
    //保存ボタンが押されたらsaveDateが呼ばれ画面が戻る
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //画面遷移した後の初期画面に関するメソッド
    private func setupView() {
        navigationItem.title = date.string(format: "yyyy/MM/dd")
        diaryData.allData()//diaryData.allDataを呼びrealmに保存される
        locationManager.setupLocationManager()//locationManagerのsetupLocationManagerを呼ぶ
        editDiaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        editDiaryTextView.layer.cornerRadius = 10
        editDiaryTextView.sizeToFit()
        weatherView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        editDiaryTextView.text = diaryData.getEventData(selectDate: date)//保存された日記をeditDiaryTextViewに表示させる
    }
    
    private func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    
    //getWeatherInfo
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
                        //                        let json = JSON(response.data as Any)
                        //                        self.maxTemp.text = "\(Int(json["main"]["temp_max"].number!).description)℃"
                        //                        self.minimumTemp.text = "\(Int(json["main"]["temp_min"].number!).description)℃"
                    }
                case .failure(let failure):
                    self.weatherLabel.text = "天気情報を取得できませんでした"
                }
            }
        }
    }
    //    print("calendar🟥\(calendar)")
    
    private func saveDate() {
        if editDiaryTextView.text == "" { return }// editDiaryTextViewに文字がなければ保存しない
        //diaryData.getEventData
        if diaryData.getEventData(selectDate: date) == "" {
            diaryData.saveData(date: date.string(format: "yyyy/MM/dd"), event: editDiaryTextView.text ?? "")
        } else {
            diaryData.updateData(selectDate: date, event: editDiaryTextView.text)
        }
        diaryData.allData()
    }
}
