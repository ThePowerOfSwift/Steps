//
//  ViewController.swift
//  swift
//
//  Created by Sachin on 9/21/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add background image
        var imageView = UIImageView(image: UIImage(named: "Trail"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = self.view.frame
        self.view.addSubview(imageView)
        
        // Get widget view controller
        var storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        var widgetViewController = storyboard.instantiateViewControllerWithIdentifier("Widget") as TodayViewController
        
        // Set up widget frame
        let inset: CGFloat = 15.0
        let barHeight: CGFloat = 50.0
        let descriptionHeight: CGFloat = 110.0
        
        var widgetX = inset
        var widgetY = (CGRectGetHeight(self.view.frame) / 2.0) - (widgetViewController.preferredContentSize.height / 2.0) - 50.0
        var widgetWidth = CGRectGetWidth(self.view.frame) - inset * 2
        var widgetHeight = widgetViewController.preferredContentSize.height
        widgetViewController.view.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)
        
        // Add background view
        var blurEffect = UIBlurEffect(style: .Dark)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        self.view.addSubview(blurView)
        
        // Add child view controller
        self.addChildViewController(widgetViewController)
        self.view.addSubview(widgetViewController.view)
        widgetViewController.didMoveToParentViewController(self)
        
        // Add widget label background
        var labelBackground = UIView(frame: CGRectMake(0.0, widgetY - barHeight, CGRectGetWidth(self.view.frame), barHeight - 15.0))
        labelBackground.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.view.addSubview(labelBackground)
        
        // Add widget label
        var label = UILabel(frame: CGRectMake(inset, widgetY - barHeight, CGRectGetWidth(self.view.frame), barHeight - 15.0))
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor.whiteColor()
        label.text = "Steps"
        self.view.addSubview(label)
        
        // Add bottom line
        var line = UIView(frame: CGRectMake(0.0, CGRectGetMaxY(widgetViewController.view.frame) + 20.0, CGRectGetWidth(self.view.frame), 0.5))
        line.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        self.view.addSubview(line)
        
        // Add vibrancy effect
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        var vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        let vibrancyViewInset = inset * 2
        vibrancyView.frame = CGRectMake(vibrancyViewInset, CGRectGetMaxY(line.frame), CGRectGetWidth(self.view.frame) - vibrancyViewInset * 2, descriptionHeight)
        
        // Add description label
        var descriptionLabel = UILabel(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(vibrancyView.frame), CGRectGetHeight(vibrancyView.frame)))
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        descriptionLabel.textAlignment = .Center
        descriptionLabel.text = "Keep track of your daily activity, right from Notification Center."
        descriptionLabel.numberOfLines = 3
        vibrancyView.contentView.addSubview(descriptionLabel)
        blurView.contentView.addSubview(vibrancyView)
        
        // Add title label
        let titleHeight: CGFloat = 50.0
        var titleLabel = UILabel(frame: CGRectMake(0.0, CGRectGetMinY(labelBackground.frame) - 25.0 - titleHeight, CGRectGetWidth(self.view.frame), titleHeight))
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 36.0)
        titleLabel.alpha = 0.9
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.text = "Steps"
        self.view.addSubview(titleLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

