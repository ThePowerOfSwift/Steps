//
//  UIColor+AppColors.swift
//  Steps
//
//  Created by Sachin Patel on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import Foundation
import UIKit

extension NSDate {
    class var midnight: NSDate {
    var calendar = NSCalendar.autoupdatingCurrentCalendar()
        var components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        return calendar.dateFromComponents(calendar.components(components, fromDate: NSDate()))!
    }
}
