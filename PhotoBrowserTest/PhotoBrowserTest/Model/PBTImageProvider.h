//
//  PBTImageProvider.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PBTImageProviderFetchCompletion)(UIImage *inImage, NSError *inError);

@interface PBTImageProvider : NSObject

+ (instancetype)sharedProvider;

// Tries to get the image from cache. May return nil.
- (UIImage *)imageAtURL:(NSURL *)aURL;
- (void)fetchImageAtURL:(NSURL *)aURL completion:(PBTImageProviderFetchCompletion)aCompletion;

- (void)resetCache;

@end
