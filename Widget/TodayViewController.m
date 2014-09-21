//
//  TodayViewController.m
//  Widget
//
//  Created by Sachin on 7/30/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

#import "TodayViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <NotificationCenter/NotificationCenter.h>
#import <QuartzCore/QuartzCore.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, weak) IBOutlet UILabel *stepCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *mileCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *floorCountLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *todayProgressView;

@property (nonatomic) NSInteger stepCount;
@property (nonatomic) CGFloat mileCount;
@property (nonatomic) NSInteger floorCount;

@property (nonatomic, strong) NSMutableArray *lastWeek;
@property (nonatomic, strong) CMPedometer *pedometer;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPreferredContentSize:CGSizeMake(320.0, 110.0f)];
    
    self.todayProgressView.layer.cornerRadius = 5.0;
    self.todayProgressView.layer.masksToBounds = YES;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    _stepCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"stepCount"] integerValue];
    [self updateLabels];
    
    if ([CMPedometer isStepCountingAvailable]) {
        _pedometer = [CMPedometer new];
        
        [_pedometer queryPedometerDataFromDate:[self midnightForDate:[NSDate date]] toDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            _stepCount = data.numberOfSteps.integerValue;
            _mileCount = data.distance.floatValue * 0.000621371; // convert meters to miles
            _floorCount = data.floorsAscended.integerValue;
            
            [self updateLabels];
            
            [_pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
                _stepCount += data.numberOfSteps.integerValue;
                _mileCount += data.distance.floatValue * 0.000621371; // convert meters to miles
                _floorCount += data.floorsAscended.integerValue;
                
                [self updateLabels];
            }];
        }];
    }
}

- (NSDate *)midnightForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSInteger units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    return [calendar dateFromComponents:[calendar components:units fromDate:date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Motion

- (void)updateLabels {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_stepCount < 10000) {
                _stepCountLabel.text = [NSString stringWithFormat:@"%ld", _stepCount];
            }
            else {
                NSNumber *number = [NSNumber numberWithDouble:_stepCount];
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [numberFormatter setGroupingSeparator:@","];
                _stepCountLabel.text = [numberFormatter stringForObjectValue:number];
            }
            
            _mileCountLabel.text = [NSString stringWithFormat:@"%.2f mile%@", _mileCount, _mileCount != 1.0 ? @"s" : @""];
            _floorCountLabel.text = [NSString stringWithFormat:@"%ld floor%@", _floorCount, _floorCount != 1 ? @"s" : @""];
            
            CGFloat percent = (CGFloat)_stepCount / 10000.0;
            _todayProgressView.progress = percent;
            
            if (percent < 0.60) {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            }
            else if (percent < 0.95) {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:0.0/255.0 alpha:1.0];
            }
            else {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
            }
            
        });
    });
}

#pragma mark - Widget Handling

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [[NSUserDefaults standardUserDefaults] setValue:@(_stepCount) forKey:@"stepCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

@end
