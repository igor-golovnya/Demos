//
//  TLTwit.h
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
@class CLLocation;
@protocol MKAnnotation;

////////////////////////////////////////////////////////////////////////////////
@interface TLTweet : NSObject

+ (instancetype)tweetWithStatusInfo:(NSDictionary *)inInfo;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSURL *profileImageUrl;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) UIImage *profileImage;

@property (nonatomic, strong) NSString *creationDate;

@end

////////////////////////////////////////////////////////////////////////////////
@interface TLTweet (Creation)

+ (instancetype)tweetWithAnnotation:(id<MKAnnotation>)inAnnotation;

@end