//
//  PBTBrowserItem.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBTBrowserItem : NSObject

@property (nonatomic, assign) NSUInteger id;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, readonly) NSURL *thumbnailImageURL;

@end
