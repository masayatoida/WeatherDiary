//
//  Date+WeatherDiary.swift
//  WeatherDiary
//
//  Created by 吉澤翔吾 on 2022/04/08.
//

import Foundation

extension Date {
    func string(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
