//
//  TodayViewController.swift
//  Steps
//
//  Created by Sachin on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import Foundation
import NotificationCenter
import CoreMotion
import QuartzCore

class TodayViewController: UIViewController, NCWidgetProviding {
    
    enum UnitSystem {
        case UnitSystemImperial
        case UnitSystemMetric
    }
    
    enum StepCountLevel: Double {
        case Low = 0.4
        case Medium = 0.8
        case High = 1.0
    }
    
    let stepCountKey = "TodayViewStepCount"
    let floorCountKey = "TodayViewFloorCount"
    let distanceKey = "TodayViewDistance"
    
    let userGoal = 10_000.0
    let widgetHeight = 78.0
    
    let distanceUnitWord = "mile"
    let mileInMeters = 1609.344
    
    @IBOutlet var stepCountLabel: UILabel?
    @IBOutlet var progressView: UIProgressView?
    
    @IBOutlet var vibrancyView: UIVisualEffectView?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var floorCountLabel: UILabel?
    
    var stepCount: Int
    var distance: Double
    var floorCount: Int
    var pedometer: CMPedometer?
    
    override init() {
        stepCount = 0
        distance = 0.0
        floorCount = 0
        super.init()
        preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, CGFloat(widgetHeight))
    }
    
    required init(coder aDecoder: NSCoder) {
        stepCount = 0
        distance = 0.0
        floorCount = 0
        super.init(coder: aDecoder)
        preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, CGFloat(widgetHeight))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        progressView!.layer.cornerRadius = 8.0
        progressView!.layer.masksToBounds = true
        
        // Read from user defaults to show while updating data
        stepCount = NSUserDefaults.standardUserDefaults().integerForKey(stepCountKey)
        distance = NSUserDefaults.standardUserDefaults().doubleForKey(distanceKey)
        floorCount = NSUserDefaults.standardUserDefaults().integerForKey(floorCountKey)
        updateLabels()
        beginUpdating()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setInteger(stepCount, forKey: stepCountKey)
        NSUserDefaults.standardUserDefaults().setDouble(distance, forKey: distanceKey)
        NSUserDefaults.standardUserDefaults().setInteger(floorCount, forKey: floorCountKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func beginUpdating () {
        // Ensure device has motion coprocessor
        if CMPedometer.isStepCountingAvailable() {
            
            // Get data from midnight to now
            pedometer = CMPedometer()
            pedometer?.queryPedometerDataFromDate(NSDate.midnight, toDate: NSDate(), withHandler: {
                data, error in
                
                // Store data
                self.stepCount = data.numberOfSteps.integerValue
                if CMPedometer.isDistanceAvailable() {
                    self.distance = data.distance.doubleValue / self.mileInMeters
                }
                if CMPedometer.isFloorCountingAvailable() {
                    self.floorCount = data.floorsAscended.integerValue + data.floorsDescended.integerValue
                }
                self.updateLabels()
                
                // Update as user moves
                self.pedometer?.startPedometerUpdatesFromDate(NSDate(), withHandler: {
                    data, error in
                    
                    // Add to existing counts
                    self.stepCount += data.numberOfSteps.integerValue
                    if CMPedometer.isDistanceAvailable() {
                        self.distance += data.distance.doubleValue / self.mileInMeters
                    }
                    if CMPedometer.isFloorCountingAvailable() {
                        self.floorCount += data.floorsAscended.integerValue + data.floorsDescended.integerValue
                    }
                    self.updateLabels()
                })
            })
        }
    }
    
    func updateLabels () {
        dispatch_async(dispatch_get_main_queue(), {
            
            // Update step count label, format nicely
            if self.stepCount < 10000 {
                self.stepCountLabel!.text = "\(self.stepCount)"
            } else {
                var number = NSNumber(integer: self.stepCount)
                var formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.groupingSeparator = ","
                self.stepCountLabel!.text = formatter.stringForObjectValue(number)
            }
            
            // Update distance label if available
            if CMPedometer.isDistanceAvailable() {
                // Update mile count label
                self.distanceLabel!.hidden = false
                self.distanceLabel!.text = NSString(format: "%.2f %@%@", self.distance, self.distanceUnitWord, (self.distance != 1) ? "s" : "")
            } else {
                self.distanceLabel!.hidden = true
            }
            
            // Update floor label if available
            if CMPedometer.isFloorCountingAvailable() {
                self.floorCountLabel!.hidden = false
                self.floorCountLabel!.text = NSString(format: "%ld floor%@", self.floorCount, (self.distance != 1) ? "s" : "")
            } else {
                self.floorCountLabel!.hidden = true
            }
            
            // Update progress indicator
            var percent = Double(self.stepCount) / self.userGoal
            self.progressView!.progress = Float(percent)
            switch percent {
                case 0...StepCountLevel.Low.toRaw():
                    self.progressView!.progressTintColor = UIColor.appRedColor()
                case StepCountLevel.Low.toRaw()...StepCountLevel.Medium.toRaw():
                    self.progressView!.progressTintColor = UIColor.appYellowColor()
                case StepCountLevel.Medium.toRaw()...StepCountLevel.High.toRaw():
                    self.progressView!.progressTintColor = UIColor.appGreenColor()
                default:
                    self.progressView!.progressTintColor = UIColor.darkGrayColor()
            }
        })
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // top, left, bottom, right
        return UIEdgeInsetsMake(15.0, 47.0, 15.0, 15.0)
    }
}