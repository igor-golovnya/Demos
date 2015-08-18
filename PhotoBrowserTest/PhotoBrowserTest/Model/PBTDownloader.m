//
//  PBTDownloader.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTDownloader.h"
#import "PBTBrowserItem.h"

#import "TBXML.h"

static NSString *const kPBTDownloaderMetadataURLString = @"https://dl.dropboxusercontent.com/u/90314326/photos.xml";

@interface PBTDownloader ()

@property (nonatomic, readonly) NSURLSession *session;

@end

@implementation PBTDownloader

@synthesize session = _session;

- (void)downloadMetadataWithCompletion:(PBTDownloaderCompletionBlock)aCompletion
{
    if (nil == aCompletion)
    {
        return;
    }
    
    [[self.session dataTaskWithURL:[NSURL URLWithString:kPBTDownloaderMetadataURLString]
        completionHandler:
    ^(NSData *inData, NSURLResponse *inResponse, NSError *inError)
    {
        if (nil != inError)
        {
            aCompletion(nil, inError);
        }
        
        if (nil != inData)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                NSError *error = nil;
                TBXML *tbxml = [[TBXML alloc] initWithXMLData:inData error:&error];
                if (nil != error)
                {
                    aCompletion(nil, error);
                    return;
                }
                
                NSMutableArray *items = [NSMutableArray new];
                assert([[TBXML elementName:tbxml.rootXMLElement] isEqualToString:@"photos"]);
                if ([[TBXML elementName:tbxml.rootXMLElement] isEqualToString:@"photos"])
                {
                    [self parseElement:tbxml.rootXMLElement->firstChild intoArray:items];
                    aCompletion(items, nil);
                }
            });
        }
    }] resume];
}

- (void)downloadDataAtURL:(NSURL *)aURL completion:(PBTDownloaderDataCompletionBlock)aCompletion
{
    if (nil == aCompletion || nil == aURL)
    {
        return;
    }
    
    [[self.session dataTaskWithURL:aURL completionHandler:
    ^(NSData *inData, NSURLResponse *inResponse, NSError *inError)
    {
        aCompletion(inData, inError);
    }] resume];
}

- (void)parseElement:(TBXMLElement *)anElement intoArray:(NSMutableArray *)anItems
{
    TBXMLElement *currentElement = anElement;
    do
    {
        PBTBrowserItem *newItem = [PBTBrowserItem new];
        [TBXML iterateAttributesOfElement:currentElement withBlock:
        ^(TBXMLAttribute *inAttribute, NSString *inName, NSString *inValue)
        {
            assert(nil != inValue);
            if ([inName isEqualToString:@"id"])
            {
                newItem.id = inValue.integerValue;
            }
            else if ([inName isEqualToString:@"url"])
            {
                newItem.imageURL = [NSURL URLWithString:inValue];
            }
            else if ([inName isEqualToString:@"title"])
            {
                newItem.title = inValue;
            }
        }];
        
        [anItems addObject:newItem];
    } while ((currentElement = currentElement->nextSibling));
}

#pragma mark -
- (NSURLSession *)session
{
    if (nil == _session)
    {
        NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:nil
            delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

@end
