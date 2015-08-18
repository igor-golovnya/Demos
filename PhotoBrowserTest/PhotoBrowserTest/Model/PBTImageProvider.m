//
//  PBTImageProvider.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTImageProvider.h"
#import "PBTDownloader.h"

@interface PBTImageProvider ()

@property (nonatomic, readonly) NSMutableDictionary *imageCache;
@property (nonatomic, readonly) PBTDownloader *downloader;

@end

@implementation PBTImageProvider

@synthesize imageCache = _imageCache;
@synthesize downloader = _downloader;

+ (instancetype)sharedProvider
{
    static PBTImageProvider *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sInstance = [PBTImageProvider new];
    });
    
    return sInstance;
}

- (UIImage *)imageAtURL:(NSURL *)aURL
{
    if (nil == aURL)
    {
        return nil;
    }
    
    return self.imageCache[aURL];
}

- (void)fetchImageAtURL:(NSURL *)aURL completion:(PBTImageProviderFetchCompletion)aCompletion
{
    if (nil == aCompletion || nil == aURL)
    {
        return;
    }
    
    UIImage *image = [self imageAtURL:aURL];
    if (nil != image)
    {
        aCompletion(image, nil);
        return;
    }
    
    [self.downloader downloadDataAtURL:aURL completion:
    ^(NSData *inData, NSError *inError)
    {
        UIImage *image = nil;
        if (nil != inData)
        {
            image = [[UIImage alloc] initWithData:inData];
            if (image)
            {
                self.imageCache[aURL] = image;
            }
        }
        
        aCompletion(image, inError);
    }];
}

- (void)resetCache
{
    [self.imageCache removeAllObjects];
}

- (NSMutableDictionary *)imageCache
{
    if (nil == _imageCache)
    {
        _imageCache = [NSMutableDictionary new];
    }
    
    return _imageCache;
}

- (PBTDownloader *)downloader
{
    if (nil == _downloader)
    {
        _downloader = [PBTDownloader new];
    }
    
    return _downloader;
}

@end
