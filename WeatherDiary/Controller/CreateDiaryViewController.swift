//
//  CreateDiaryViewController.swift
//  WeatherDiary
//
//  Created by 戸井田莉江 on 2022/02/28.
//

import UIKit

class CreateDiaryViewController: UIViewController {
    
    @IBOutlet private weak var eventTextfield: UITextField!
    
    var date = Date()
    private let diaryData = DiaryData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let df =  DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        navigationItem.title = df.string(from: date)
        diaryData.allData()
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveDate()
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapDelete(_ sender: UIButton) {
    }
    
    private func saveDate() {
        let df =  DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        diaryData.saveData(date: df.string(from: date), event: eventTextfield.text ?? "")
        diaryData.allData()
    }
}
