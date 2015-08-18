//
//  UIView+PBTAdditions.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "UIView+PBTAdditions.h"

static NSString *const kAnimationName = @"360Rotation";

@implementation UIView (PBTAdditions)

- (void)pbt_rotate360WithDuration:(CGFloat)duration repeatCount:(float)repeatCount
{
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    fullRotation.duration = duration;
    fullRotation.speed = 1.0f;
    if (0 == repeatCount)
    {
        fullRotation.repeatCount = MAXFLOAT;
    }
    else
    {
        fullRotation.repeatCount = repeatCount;
    }

    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.layer addAnimation:fullRotation forKey:kAnimationName];
}

- (void)pbt_stopRotationAnimation
{
    [self.layer removeAnimationForKey:kAnimationName];
}

@end
