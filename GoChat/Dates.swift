//
//  Dates.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

private let FORMAT_ISO_8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

extension NSDate
{
    struct Formatter {
        static let iso8601: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = FORMAT_ISO_8601
            return dateFormatter
        }()
    }
    
    /**
     Returns an integer timestamp in milliseconds
     */
    func timestamp() -> Int
    {
        let timeInterval = self.timeIntervalSince1970
        let timestamp = Int(timeInterval * 1000) // for milliseconds
        return timestamp
    }
    
    var iso8601Date: String {
        return NSDate.Formatter.iso8601.string(from: Date())
    }
    
    convenience init?(iso8601: String)
    {
        if let date = NSDate.Formatter.iso8601.date(from: iso8601) {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        } else {
            return nil
        }
    }
    
    func timeAgo() -> String
    {
        return NSDate.timeAgoSinceDate(date: self)
    }
    
    static func timeAgoSinceDate(date: NSDate) -> String
    {
//        let calendar = NSCalendar.current
//        let now = NSDate()
        //time delta
//        let earliest = now.earlierDate(date as Date)
//        let latest = (earliest == now as Date) ? date : now
//        let components = calendar.dateComponents([.minute , .hour , .day , .weekOfYear , .month , .year , .second], from: earliest, to: latest as Date)
        
//        if (components.year! >= 1)
//        {
//            return "\(components.year)y"
//        }
//        else if (components.month! >= 1)
//        {
//            return "\(components.month)m"
//        }
//        else if (components.weekOfYear! >= 1)
//        {
//            return "\(components.weekOfYear)w"
//        }
//        else if (components.day! >= 1)
//        {
//            return "\(components.day)d"
//        }
//        else if (components.hour! >= 1)
//        {
//            return "\(components.hour)h"
//        }
//        else if (components.minute! >= 1)
//        {
//            return "\(components.minute)m"
//        }
//        return "🔥"
        
        let date = date as Date
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute , .hour , .day , .weekOfYear , .month , .year , .second], from: date, to: now)
        
        if let numYears = components.year, numYears >= 1
        {
            return "\(numYears)y"
        }
        else if let numMonths = components.month, numMonths >= 1
        {
            return "\(numMonths)m"
        }
        else if let numWeeks = components.weekOfYear, numWeeks >= 1
        {
            return "\(numWeeks)w"
        }
        else if let numDays = components.day, numDays >= 1
        {
            return "\(numDays)d"
        }
        else if let numHours = components.hour, numHours >= 1
        {
            return "\(numHours)h"
        }
        else if let numMinutes = components.minute, numMinutes >= 1
        {
            return "\(numMinutes)m"
        }
        return "🔥"

        
//        if calendar.component(.year, from: date) >= 1 {
//            return "\(calendar.component(.year, from: date))"
//        } else if calendar.component(.month, from: date) >= 1 {
//            return "\(calendar.component(.month, from: date))"
//        } else if calendar.component(.weekOfYear, from: date) >= 1 {
//            return "\(calendar.component(.weekOfYear, from: date))"
//        } else if calendar.component(.day, from: date) >= 1 {
//            return "\(calendar.component(.day, from: date))"
//        } else if calendar.component(.hour, from: date) >= 1 {
//            return "\(calendar.component(.hour, from: date))"
//        } else if calendar.component(.minute, from: date) >= 1 {
//            return "\(calendar.component(.minute, from: date))"
//        }
//        return "🔥"
        
        
        //try this out for the above bullshit and optionals
//        let date = Date()
//        let calendar = Calendar.current
//        
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
//        print("hours = \(hour):\(minutes):\(seconds)")
        
        
    }
}
