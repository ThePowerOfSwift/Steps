//
//  Header.swift
//  Steps
//
//  Created by Sachin Patel on 9/24/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import Foundation

// MARK: - User Defaults

let StepCountKey = "TodayViewStepCount"
let FloorCountKey = "TodayViewFloorCount"
let DistanceKey = "TodayViewDistance"
let UserGoalKey = "TodayViewUserGoal"
let UnitTypeKey = "TodayViewUnitType"
let UnitDisplayKey = "TodayViewUnitDisplay"
let defaultsSuiteName = "group.SachinPatel.Steps.TodayExtensionSharingDefaults"

// MARK: - Units

enum UnitSystem: Int {
    case Imperial = 0
    case Metric = 1
}

enum UnitDisplay: Int {
    case Short = 0
    case Long = 1
}

// Unit Conversions
let mileInMeters = 1609.344

let UnitSystemImperialWord = "mile"
let UnitSystemMetricWord = "kilometer"

let UnitSystemImperialWordShort = "mi"
let UnitSystemMetricWordShort = "km"