//
// ShowCalenderViewController.swift
// WeatherDiary
//
// Created by 戸井田莉江 on 2022/02/28.
// 参考: - https://qiita.com/yuki1023/items/9f3416ac3c687fa31a52

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class ShowCalenderViewController: UIViewController {
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var diaryTextView: UITextView!
    
    // カレンダーフォーマットに関する記述
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var selectDate = Date() // selectDateに今日の日付を入れる
    private let locationManager = LocationManager() // LocationManagerクラスをインスタンス化
    private let diaryData = DiaryData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.setupLocationManager() // LocationManagerのsetupLocationManagerを呼ぶ
        setupView()
    }
    
    @IBAction func didTapToCreateDiary(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CreateDiary", bundle: nil)
        let createDiaryVC = storyboard.instantiateViewController(withIdentifier: "CreateDiary") as! CreateDiaryViewController
        createDiaryVC.date = selectDate // selectDateには今日の日付が入っているが画面遷移の時には選択した日を渡す
        self.navigationController?.pushViewController(createDiaryVC, animated: true)
    }
    
    private func setupView() {
        self.calendar.dataSource = self
        self.calendar.delegate = self
        diaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        diaryTextView.layer.cornerRadius = 10
        diaryTextView.sizeToFit()
        plusButton.layer.cornerRadius = plusButton.bounds.width/2
        plusButton.layer.shadowOpacity = 0.1
        plusButton.layer.shadowRadius = 3
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
        diaryTextView.text = diaryData.getEventData(selectDate: selectDate)  // diaryTextViewにgetEventDataで保存された内容を表示。
    }
}

extension ShowCalenderViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if self.judgeHoliday(date) { return .red }
        let weekday = self.getWeekIdx(date)
        if weekday == 1 { return .red }
        if weekday == 7 { return .blue }
        return nil
    }
    
    // 日付を選択したときに呼ばれるメソッド
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDate = date // ここのdateでselectDateには選択された日付が入るので画面遷移時には選択された日付が渡される
        let today = Date()
        diaryTextView.isHidden = selectDate > today
        plusButton.isHidden = selectDate > today
        diaryTextView.text = diaryData.getEventData(selectDate: selectDate)
    }
    // カレンダーの祝日に関するメソッド
    private func judgeHoliday(_ date: Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // 1週間の情報を取得するためのメソッド
    private func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
}
