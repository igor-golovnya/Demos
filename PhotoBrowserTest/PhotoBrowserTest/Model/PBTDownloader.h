//
//  PBTDownloader.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Returns an array of PBTBrowserItem instances
typedef void(^PBTDownloaderCompletionBlock)(NSArray *inBrowserItems, NSError *inError);
typedef void(^PBTDownloaderDataCompletionBlock)(NSData *inData, NSError *inError);

@interface PBTDownloader : NSObject

- (void)downloadMetadataWithCompletion:(PBTDownloaderCompletionBlock)aCompletion;
- (void)downloadDataAtURL:(NSURL *)aURL completion:(PBTDownloaderDataCompletionBlock)aCompletion;

@end
