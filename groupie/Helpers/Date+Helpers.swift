//
//  Date+Helpers.swift
//  Groupie
//
//  Created by Sania on 28.07.17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

extension Date {
  
  // MARK: -
  
  init?(dateString: String, format: String, timezone: TimeZone = TimeZone(abbreviation: "UTC")!) {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = timezone
    guard let date = formatter.date(from: dateString) else {
      self.init()
      return nil
    }
    self.init(timeIntervalSince1970: date.timeIntervalSince1970)
  }
    
    init?(dateString: String, timezone: TimeZone = TimeZone(abbreviation: "UTC")!) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = timezone
        guard let date = formatter.date(from: dateString) else {
            self.init()
            return nil
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
  
  func toString(format: String, timezone: TimeZone = TimeZone.current) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = timezone
    return formatter.string(from: self)
  }
  
  //MARK: -
  
  func components() -> DateComponents {
    return (Calendar.current as NSCalendar).components(NSCalendar.Unit(rawValue: UInt.max), from: self)

  }
  
  func dateByChanging(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, timezone: TimeZone? = nil) -> Date {
    var components = self.components()
    if let year = year     { components.year! = year }
    if let month = month   { components.month! = month }
    if let day = day       { components.day! = day }
    if let hour = hour     { components.hour! = hour }
    if let minute = minute { components.minute! = minute }
    if let second = second { components.second! = second }
    if let timezone = timezone { (components as NSDateComponents).timeZone = timezone }
    return Calendar.current.date(from: components)!
  }
  
  func dateByAdding(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
    var components = self.components()
    if let year = year     { components.year! += year}
    if let month = month   { components.month! += month }
    if let day = day       { components.day! += day }
    if let hour = hour     { components.hour! += hour }
    if let minute = minute { components.minute! += minute }
    if let second = second { components.second! += second }
    return Calendar.current.date(from: components)!
  }
  
  // MARK: -
  
  func isEqualToDate(_ otherDate: Date, ignoreTime: Bool) -> Bool {
    if ignoreTime {
      let comp1 = self.components()
      let comp2 = otherDate.components()
      return ((comp1.year == comp2.year) && (comp1.month == comp2.month) && (comp1.day == comp2.day))
    } else {
      return (self == otherDate)
    }
  }
  
    func agoFromDate(date: Date) -> String {
        var interval = self.timeIntervalSince(date)
        if (interval < 60) {
            return String.init(format: "%.0fs", interval)
        }
        interval /= 60
        if (interval < 60) {
            return String.init(format: "%.0fm", interval)
        }
        interval /= 60
        if (interval < 24) {
            return String.init(format: "%.0fh", interval)
        }
        interval /= 24
        if (interval < 31) {
            return String.init(format: "%.0fd", interval)
        }
        interval /= 31
        if (interval < 12) {
            return String.init(format: "%.0fmon", interval)
        }
        interval /= 12
        return String.init(format: "%.0fy", interval)
    }
}
