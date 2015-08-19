//
//  TLTwit.m
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import "TLTweet.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

////////////////////////////////////////////////////////////////////////////////
#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

////////////////////////////////////////////////////////////////////////////////
@implementation TLTweet

@synthesize status = _status;
@synthesize profileImageUrl = _profileImageUrl;
@synthesize username = _username;
@synthesize location = _location;
@synthesize profileImage = _profileImage;
@synthesize creationDate = _creationDate;

+ (instancetype)tweetWithStatusInfo:(NSDictionary *)inInfo
{
	TLTweet *tweet = [TLTweet new];
	
	if ([inInfo isKindOfClass:[NSDictionary class]])
	{
		tweet.status = inInfo[@"text"];
		tweet.creationDate = inInfo[@"created_at"];

		NSDictionary *userInfo = inInfo[@"user"];
		if ([userInfo isKindOfClass:[NSDictionary class]])
		{
			tweet.username = userInfo[@"screen_name"];
			NSString *urlString = userInfo[@"profile_image_url"];
			if (nil != urlString)
			{
				tweet.profileImageUrl = [NSURL URLWithString:urlString];
			}
			
			NSDictionary *geoInfo = inInfo[@"geo"];
			if ([geoInfo isKindOfClass:[NSDictionary class]]
                && [geoInfo[@"type"] isEqualToString:@"Point"])
			{
				NSArray *coorditanes = geoInfo[@"coordinates"];
				if (2 == coorditanes.count)
				{
					CLLocation *location = [[CLLocation alloc] initWithLatitude:
                        [coorditanes[0] doubleValue] longitude:[coorditanes[1]
                        doubleValue]];
					
					tweet.location = location;
				}
			}
		}
	}
		
	return tweet;
}

+ (instancetype)tweetWithAnnotation:(id<MKAnnotation>)inAnnotation
{
	TLTweet *annotataionTweet = [TLTweet new];
	
	annotataionTweet.username = inAnnotation.title;
	annotataionTweet.status = inAnnotation.subtitle;
	annotataionTweet.location = [[CLLocation alloc] initWithLatitude:
        inAnnotation.coordinate.latitude
        longitude:inAnnotation.coordinate.longitude];
	
	return annotataionTweet;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"TLTweet: username: %@, status: %@, "
        "location: { %f, %f }, profileImage: %@", self.username, self.status,
        self.location.coordinate.latitude, self.location.coordinate.longitude,
        self.profileImage];
}

// Support for comparing tweets
- (BOOL)isEqual:(TLTweet *)inObject
{
	if ([super isEqual:inObject])
	{
		return YES;
	}
	if (![inObject isKindOfClass:[self class]])
	{
		return NO;
	}
	
	return [self.username isEqualToString:inObject.username]
        && [self.status isEqualToString:inObject.status]
        && CLCOORDINATES_EQUAL(self.location.coordinate,
        inObject.location.coordinate);
}

- (NSUInteger)hash
{
	return self.username.hash ^ self.status.hash ^ self.location.hash;
}

@end
