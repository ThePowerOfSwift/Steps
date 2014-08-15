//
//  DayCollectionViewCell.m
//  Steps
//
//  Created by Sachin on 7/30/14.
//  Copyright (c) 2014 Sachin Patel. All rights reserved.
//

#import "DayCollectionViewCell.h"

@interface DayCollectionViewCell ()
@property (nonatomic, strong) UIView *progressView;
@end

@implementation DayCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse {
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

- (void)setPercent:(CGFloat)percent {
    CGFloat height = self.frame.size.height * percent;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - height, self.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1];
    [self addSubview:view];
}

@end
