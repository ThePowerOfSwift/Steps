//
//  ViewController.swift
//  Steps
//
//  Created by Sachin Patel on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Interface Elements
    @IBOutlet var topLine: UIView?
    @IBOutlet var bottomLine: UIView?
    @IBOutlet var blurView: UIVisualEffectView?
    var unitTypePicker: UISegmentedControl?
    var unitDisplayPicker: UISegmentedControl?
    var goalPicker: UISegmentedControl?
    
    // Interface Constants
    let inset: CGFloat = 15.0
    let descriptionHeight: CGFloat = 110.0
    
    // User Defaults
    var sharedDefaults: NSUserDefaults!
    var unitSystemType: Int {
        get {
            return sharedDefaults.integerForKey(UnitTypeKey)
        }
        set {
            sharedDefaults.setInteger(newValue, forKey: UnitTypeKey)
        }
    }
    var unitDisplayType: Int {
        get {
            return sharedDefaults.integerForKey(UnitDisplayKey)
        }
        set {
            sharedDefaults.setInteger(newValue, forKey: UnitDisplayKey)
        }
    }
    var userGoal: Float {
        get {
            return sharedDefaults.floatForKey(UserGoalKey)
        }
        set {
            sharedDefaults.setFloat(newValue, forKey: UserGoalKey)
        }
    }
    
    required override init () {
        sharedDefaults = NSUserDefaults(suiteName: defaultsSuiteName)
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        sharedDefaults = NSUserDefaults(suiteName: defaultsSuiteName)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }
    
    func setupInterface () {
        addWidget()
        
        // Vibrancy Effect
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        var vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = self.view.frame
        self.view.addSubview(vibrancyView)
        
        // Unit Type
        unitTypePicker = UISegmentedControl(frame: CGRectMake(inset, CGRectGetMaxY(bottomLine!.frame) + inset * 2, CGRectGetWidth(self.view.frame) - inset * 2, 40.0))
        unitTypePicker!.insertSegmentWithTitle("Miles", atIndex: 0, animated: false)
        unitTypePicker!.insertSegmentWithTitle("Kilometers", atIndex: 1, animated: false)
        unitTypePicker!.selectedSegmentIndex = 0
        unitTypePicker!.addTarget(self, action: "segmentChanged", forControlEvents: .ValueChanged)
        vibrancyView.contentView.addSubview(unitTypePicker!)
        
        // Unit Display
        unitDisplayPicker = UISegmentedControl(frame: CGRectMake(inset, CGRectGetMaxY(unitTypePicker!.frame) + inset * 2, CGRectGetWidth(self.view.frame) - inset * 2, 40.0))
        unitDisplayPicker!.insertSegmentWithTitle("Abbreviation", atIndex: 0, animated: false)
        unitDisplayPicker!.insertSegmentWithTitle("Full Unit Name", atIndex: 1, animated: false)
        unitDisplayPicker!.selectedSegmentIndex = 0
        unitDisplayPicker!.addTarget(self, action: "segmentChanged", forControlEvents: .ValueChanged)
        vibrancyView.contentView.addSubview(unitDisplayPicker!)
        
        // User Goal
        goalPicker = UISegmentedControl(frame: CGRectMake(inset, CGRectGetMaxY(unitDisplayPicker!.frame) + inset * 2, CGRectGetWidth(self.view.frame) - inset * 2, 40.0))
        goalPicker!.insertSegmentWithTitle("2500", atIndex: 0, animated: false)
        goalPicker!.insertSegmentWithTitle("5000", atIndex: 1, animated: false)
        goalPicker!.insertSegmentWithTitle("10,000", atIndex: 2, animated: false)
        goalPicker!.insertSegmentWithTitle("12,000", atIndex: 3, animated: false)
        goalPicker!.insertSegmentWithTitle("15,000", atIndex: 4, animated: false)
        goalPicker!.selectedSegmentIndex = 2
        goalPicker!.addTarget(self, action: "segmentChanged", forControlEvents: .ValueChanged)
        vibrancyView.contentView.addSubview(goalPicker!)
        
        // Add description label
        let descriptionLabelInset = inset * 2
        var descriptionLabel = UILabel(frame: CGRectMake(descriptionLabelInset, CGRectGetMaxY(self.view.frame) - descriptionHeight, CGRectGetWidth(self.view.frame) - descriptionLabelInset * 2, descriptionHeight))
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        descriptionLabel.textAlignment = .Center
        descriptionLabel.text = "Keep track of your daily activity, right from Notification Center."
        descriptionLabel.numberOfLines = 3
        vibrancyView.contentView.addSubview(descriptionLabel)
        blurView!.contentView.addSubview(vibrancyView)
        
        loadUserDefaults()
    }
    
    func addWidget () {
        // Get widget view controller
        var storyboard = UIStoryboard(name: "TodayInterface", bundle: nil)
        var widgetViewController = storyboard.instantiateViewControllerWithIdentifier("Widget") as TodayViewController
        
        var widgetY = CGRectGetMaxY(topLine!.frame) + inset
        var widgetWidth = CGRectGetWidth(self.view.frame) - inset * 2
        var widgetHeight = widgetViewController.preferredContentSize.height
        widgetViewController.view.frame = CGRectMake(inset, widgetY, widgetWidth, widgetHeight)
        
        // Add child view controller
        self.addChildViewController(widgetViewController)
        self.view.addSubview(widgetViewController.view)
        widgetViewController.didMoveToParentViewController(self)
    }
    
    func loadUserDefaults () {
        if userGoal == 0 {
            userGoal = 10_000
        }
        
        unitTypePicker!.selectedSegmentIndex = unitSystemType
    }
    
    func segmentChanged () {
        unitSystemType = unitTypePicker!.selectedSegmentIndex
        unitDisplayType = unitDisplayPicker!.selectedSegmentIndex
        
        switch goalPicker!.selectedSegmentIndex {
            case 0: userGoal = 2500
            case 1: userGoal = 5000
            case 2: userGoal = 10_000
            case 3: userGoal = 12_000
            case 4: userGoal = 15_000
            default: userGoal = 10_000
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

