//
//  TodayViewController.m
//  Widget
//
//  Created by Sachin on 7/30/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

#import "TodayViewController.h"
#import "DayCollectionViewCell.h"

#import <CoreMotion/CoreMotion.h>
#import <NotificationCenter/NotificationCenter.h>
#import <QuartzCore/QuartzCore.h>

@interface TodayViewController () <NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *lastWeek;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *stepCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *goalCountLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *todayProgressView;
@property (nonatomic) NSInteger stepCount;
@property (nonatomic, strong) CMPedometer *pedometer;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPreferredContentSize:CGSizeMake(320.0, 100.0)];
    
    self.lastWeek = [[NSMutableArray alloc] initWithCapacity:7];
    for (NSInteger i = 0; i < 7; i++) {
        self.lastWeek[i] = @(0);
    }
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 5.0f);
    _todayProgressView.transform = transform;
    
    if ([CMPedometer isStepCountingAvailable]) {
        _pedometer = [CMPedometer new];
        
        [_pedometer queryPedometerDataFromDate:[self midnightForDate:[NSDate date]] toDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            _stepCount = data.numberOfSteps.integerValue;
            [self updateSteps];
            
            [_pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
                _stepCount += data.numberOfSteps.integerValue;
                [self updateSteps];
            }];
        }];
        
        for (int i = 7; i > 1; i--) {
            NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f*i)];
            NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f*(i-1))];
            
            [_pedometer queryPedometerDataFromDate:[self midnightForDate:startDate] toDate:[self midnightForDate:endDate] withHandler:^(CMPedometerData *data, NSError *error) {
                
                _lastWeek[i] = data.numberOfSteps;
                [self.collectionView reloadData];
                
            }];
        }
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

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DayCollectionViewCell *cell = (DayCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DayCollectionViewCell" forIndexPath:indexPath];
    if (_lastWeek[indexPath.row] != nil && [_lastWeek[indexPath.row] isKindOfClass:[NSNumber class]]) {
        CGFloat percent = [_lastWeek[indexPath.row] floatValue] / 10000.0f;
        [cell setPercent:percent];
    }
    return cell;
}

#pragma mark - Core Motion

- (void)updateSteps {
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
            
            CGFloat percent = (CGFloat)_stepCount / 10000.0;
            _todayProgressView.progress = percent;
            
            if (percent < 0.60) {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:147.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:0.7];
            }
            else if (percent < 0.95) {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:0.0/255.0 alpha:0.7];
            }
            else {
                _todayProgressView.progressTintColor = [UIColor colorWithRed:19.0/255.0 green:219.0/255.0 blue:33.0/255.0 alpha:0.7];
            }
            
        });
    });
}

#pragma mark - Widget Handling

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self performSelectorOnMainThread:@selector(updateSteps) withObject:nil waitUntilDone:YES];
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

@end
