//
//  TLTweetsLocationManager.h
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
@protocol TLTweetsLocationManagerDelegate;

////////////////////////////////////////////////////////////////////////////////
extern NSString *const kTLTweetsLocationManagerErrorDomain;
typedef NS_ENUM(NSUInteger, TLTweetsLocationManagerError)
{
	kTLTweetsLocationManagerErrorAccessToTwitsDenied,
	kTLTweetsLocationManagerErrorAccessToLocationDenied,
	kTLTweetsLocationManagerErrorNoTwitAccounts,
	kTLTweetsLocationManagerErrorInvalidServerResponse
};

////////////////////////////////////////////////////////////////////////////////
/// Objects of this class are responsible for periodically retrieving a list of
/// tweets that are close to current user location
@interface TLTweetsLocationManager : NSObject

/// Starts searching for a tweets that are close to current user location. The
/// results of the search are delivered to the delegate.
- (void)startSearchingTwits;

/// Stops searching for tweets.
- (void)stopSearchingTwits;

/// Accessor to search interval. Default is 10 seconds.
@property (nonatomic, assign) NSTimeInterval updateInterval;

/// Search radius in kilometers
@property (nonatomic, assign) double searchRadius;

/// Specifies the maximum number of items that will be returned in -searchResults
/// and corresponding callback. Default is 20.
@property (nonatomic, assign) NSUInteger maxResultsCount;

/// An array that contains the results of the last search as TLTwit objects.
/// Can be nil if no search has yet finished;
@property (nonatomic, readonly) NSArray *searchResults;

/// Accessor to the delegate object. Delegate methods are guaranteed to be
/// called on the main thread. N.B.: In production code an additional property
/// like -delegateQueue can be used to specify the queue on which delegate
/// methods should be called.
@property (nonatomic, weak) id<TLTweetsLocationManagerDelegate> delegate;

@end

////////////////////////////////////////////////////////////////////////////////
@protocol TLTweetsLocationManagerDelegate <NSObject>
@optional
- (void)tweetsLocationManager:(TLTweetsLocationManager *)inManager
			didReceiveResults:(NSArray *)inResults;

- (void)tweetsLocationManager:(TLTweetsLocationManager *)inManager
			didFailWithError:(NSError *)inError;

@end
