//
//  UIColor+AppColors.swift
//  Steps
//
//  Created by Sachin on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func decimalColorWithRed(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
    
    class func appRedColor() -> UIColor {
        return UIColor.decimalColorWithRed(255, green: 59, blue: 48)
    }
    
    class func appYellowColor() -> UIColor {
        return UIColor.decimalColorWithRed(255, green: 225, blue: 0)
    }
    
    class func appGreenColor() -> UIColor {
        return UIColor.decimalColorWithRed(76, green: 217, blue: 100)
    }
}

extension NSDate {
    class var midnight: NSDate {
    var calendar = NSCalendar.autoupdatingCurrentCalendar()
        var components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        return calendar.dateFromComponents(calendar.components(components, fromDate: NSDate()))!
    }
}
