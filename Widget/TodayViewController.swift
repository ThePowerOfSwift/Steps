//
//  TodayViewController.swift
//  Steps
//
//  Created by Sachin Patel on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import Foundation
import NotificationCenter
import CoreMotion
import QuartzCore

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // Interface
    let widgetHeight = 78.0
    @IBOutlet var stepCountLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var floorCountLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    
    // Defines intervals for progress bar color
    let StepCountIntervalLow = Float(0)...Float(0.4)
    let StepCountIntervalMed = Float(0.4)...Float(0.8)
    
    // User Defaults
    var sharedDefaults: NSUserDefaults
    var unitSystemType: UnitSystem? {
        get {
            var raw = sharedDefaults.integerForKey(UnitTypeKey)
            return UnitSystem(rawValue: raw)
        }
        set {
            sharedDefaults.setInteger(newValue!.rawValue, forKey: UnitTypeKey)
            updateInterface()
        }
    }
    var unitDisplayType: UnitDisplay? {
        get {
            var raw = sharedDefaults.integerForKey(UnitDisplayKey)
            return UnitDisplay(rawValue: raw)
        }
        set {
            sharedDefaults.setInteger(newValue!.rawValue, forKey: UnitDisplayKey)
            updateInterface()
        }
    }
    var userGoal: Float {
        get {
            return sharedDefaults.floatForKey(UserGoalKey)
        }
        set {
            sharedDefaults.setFloat(newValue, forKey: UserGoalKey)
            updateInterface()
        }
    }
    var unitSystemWord: String {
        switch (unitSystemType!) {
        case .Imperial:
            switch (unitDisplayType!) {
                case .Short: return UnitSystemImperialWordShort
                case .Long: return UnitSystemImperialWord
            }
        case .Metric:
            switch (unitDisplayType!) {
            case .Short: return UnitSystemMetricWordShort
            case .Long: return UnitSystemMetricWord
            }
        }
    }
    
    // Pedometer
    var stepCount: Int
    var distance: Double
    var floorCount: Int
    var pedometer: CMPedometer
    
    // MARK: - Initializers
	
 	init() {
        stepCount = 0
        distance = 0.0
        floorCount = 0
        pedometer = CMPedometer()
        sharedDefaults = NSUserDefaults(suiteName: defaultsSuiteName)!
		super.init(nibName: nil, bundle: nil)
        preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, CGFloat(widgetHeight))
    }
    
    required init(coder aDecoder: NSCoder) {
        stepCount = 0
        distance = 0.0
        floorCount = 0
        pedometer = CMPedometer()
        sharedDefaults = NSUserDefaults(suiteName: defaultsSuiteName)!
        super.init(coder: aDecoder)
        preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, CGFloat(widgetHeight))
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set user defaults
        if userGoal == 0 {
            userGoal = 10_000
        }
        
        // Progress view appearance
        progressView.layer.cornerRadius = 8.0
        progressView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Read from user defaults to show while updating data
        stepCount = sharedDefaults.integerForKey(StepCountKey)
        distance = sharedDefaults.doubleForKey(DistanceKey)
        floorCount = sharedDefaults.integerForKey(FloorCountKey)
        
        // Update interface before
        updateInterface()
        updatePedometer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        sharedDefaults.setInteger(stepCount, forKey: StepCountKey)
        sharedDefaults.setDouble(distance, forKey: DistanceKey)
        sharedDefaults.setInteger(floorCount, forKey: FloorCountKey)
        sharedDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Widget
    func updatePedometer () {
        // Ensure device has motion coprocessor
        if CMPedometer.isStepCountingAvailable() {
            
            // Get data from midnight to now
            pedometer.queryPedometerDataFromDate(NSDate.midnight, toDate: NSDate(), withHandler: {
                data, error in
                
                if data != nil {
                    // Store data
                    self.stepCount = data.numberOfSteps.integerValue
                    if CMPedometer.isDistanceAvailable() {
                        self.distance = data.distance.doubleValue
                    }
                    if CMPedometer.isFloorCountingAvailable() {
                        self.floorCount = data.floorsAscended.integerValue + data.floorsDescended.integerValue
                    }
                    self.updateInterface()
                }
                
                // Update as user moves
                self.pedometer.startPedometerUpdatesFromDate(NSDate(), withHandler: {
                    data, error in
                    
                    if data != nil {
                        // Add to existing counts
                        self.stepCount += data.numberOfSteps.integerValue
                        if CMPedometer.isDistanceAvailable() {
                            self.distance += data.distance.doubleValue
                        }
                        if CMPedometer.isFloorCountingAvailable() {
                            self.floorCount += data.floorsAscended.integerValue + data.floorsDescended.integerValue
                        }
                        self.updateInterface()
                    }
                })
            })
        }
    }
    
    func updateInterface () {
        dispatch_async(dispatch_get_main_queue(), {
            // Update step count label, format nicely
            if self.stepCount < 10_000 {
                self.stepCountLabel.text = "\(self.stepCount)"
            } else {
                var number = NSNumber(integer: self.stepCount)
                var formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.groupingSeparator = ","
                self.stepCountLabel.text = formatter.stringForObjectValue(number)
            }
        });
        
        // Update distance label if available
        if CMPedometer.isDistanceAvailable() {
            // Update mile count label
            var convertedDistance = self.distance
            switch self.unitSystemType! {
            case .Imperial:
                convertedDistance /= mileInMeters
            case .Metric:
                convertedDistance /= 1000
            }
            
            var distanceExtension = (self.unitDisplayType == .Long && self.distance != 1) ? "s" : ""
            dispatch_async(dispatch_get_main_queue(), {
                self.distanceLabel.hidden = false
                self.distanceLabel.text = NSString(format: "%.2f %@%@", convertedDistance, self.unitSystemWord, distanceExtension) as String
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.distanceLabel.hidden = true
            });
        }
        
        // Update floor label if available
        if CMPedometer.isFloorCountingAvailable() {
            dispatch_async(dispatch_get_main_queue(), {
                self.floorCountLabel.hidden = false
                self.floorCountLabel.text = NSString(format: "%ld floor%@", self.floorCount, (self.floorCount != 1) ? "s" : "") as String
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.floorCountLabel.hidden = true
            });
        }
        
        // Update progress indicator
        var percent = min(Float(self.stepCount) / Float(self.userGoal), 1.0)
        self.progressView.setProgress(percent, animated: false)
        switch percent {
        case StepCountIntervalLow:
            self.progressView.progressTintColor = UIColor.redColor()
        case StepCountIntervalMed:
            self.progressView.progressTintColor = UIColor.yellowColor()
        default:
            self.progressView.progressTintColor = UIColor.greenColor()
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15.0, 47.0, 15.0, 15.0)
    }
}