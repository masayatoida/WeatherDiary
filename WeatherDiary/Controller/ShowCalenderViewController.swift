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
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var diaryTextView: UITextView!
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var selectDate = Date()
    private let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.setupLocationManager()
        self.calendar.dataSource = self
        self.calendar.delegate = self
        plusButton.layer.cornerRadius = 30
        diaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        diaryTextView.layer.cornerRadius = 10
        diaryTextView.sizeToFit()
    }
    
    @IBAction func didTapToCreateDiary(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CreateDiary", bundle: nil)
        let createDiaryVC = storyboard.instantiateViewController(withIdentifier: "CreateDiary") as! CreateDiaryViewController
        createDiaryVC.date = selectDate
        self.navigationController?.pushViewController(createDiaryVC, animated: true)
    }
    
    func judgeHoliday(_ date: Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    func getDay(_ date: Date) -> (Int, Int, Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year, month, day)
    }
    
    func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
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
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDate = date
    }
}
