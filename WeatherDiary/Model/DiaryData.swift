//
//  DiaryData.swift
//  WeatherDiary
//
//  Created by 戸井田莉江 on 2022/04/01.
//

import Foundation
import RealmSwift

class DiaryData: Object {
    @objc dynamic var date = ""
    @objc dynamic var event = ""
}

extension DiaryData {
    func saveData(date: String, event: String){
        let realm = try! Realm()
        let diaryData = DiaryData()
        diaryData.date = date
        diaryData.event = event
        try! realm.write {
            realm.add(diaryData)
        }
    }
    
    func allData() {
        let realm = try! Realm()
        let diaryData = realm.objects(DiaryData.self)
        print(diaryData)
    }
}
