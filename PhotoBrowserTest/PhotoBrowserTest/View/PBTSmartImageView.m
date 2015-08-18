//
//  PBTSmartImageView.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTSmartImageView.h"

#import "PBTImageProvider.h"
#import "UIView+PBTAdditions.h"

@interface PBTSmartImageView ()

@end

@implementation PBTSmartImageView

- (void)displayImageAtURL:(NSURL *)aURL
{
    NSURL *imageURL = aURL;
    UIImage *image = [[PBTImageProvider sharedProvider] imageAtURL:imageURL];
    if (image)
    {
        self.image = image;
    }
    else
    {
        self.image = [UIImage imageNamed:@"loading"];
        [self pbt_rotate360WithDuration:1 repeatCount:0];
        
        [[PBTImageProvider sharedProvider] fetchImageAtURL:imageURL completion:
        ^(UIImage *inImage, NSError *inError)
        {
            [self pbt_stopRotationAnimation];
            self.image = inImage;
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
