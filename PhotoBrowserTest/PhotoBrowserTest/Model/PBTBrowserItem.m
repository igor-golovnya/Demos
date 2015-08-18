//
//  PBTBrowserItem.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTBrowserItem.h"

@implementation PBTBrowserItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, id: %@, imageURL: %@, title: %@",
        [super description], @(self.id), self.imageURL, self.title];
}

- (NSURL *)thumbnailImageURL
{
    NSString *string = self.imageURL.absoluteString;
    NSString *extension = [string pathExtension];
    string = [[[string stringByDeletingPathExtension] stringByAppendingString:@"_s"] stringByAppendingPathExtension:extension];
    
    NSURL *result = [NSURL URLWithString:string];
    
    return result;
}

@end
