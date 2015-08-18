//
//  UIView+PBTAdditions.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PBTAdditions)

- (void)pbt_rotate360WithDuration:(CGFloat)aDuration repeatCount:(float)aRepeatCount;
- (void)pbt_stopRotationAnimation;

@end
