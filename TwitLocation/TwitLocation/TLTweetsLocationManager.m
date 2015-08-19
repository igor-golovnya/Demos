//
//  TLTweetsLocationManager.m
//  TweetLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import "TLTweetsLocationManager.h"

#import "RACEXTScope.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>

#import "TLTweet.h"

NSString *const kTLTweetsLocationManagerErrorDomain = @"com.example.tweetsLocationManagerError";


////////////////////////////////////////////////////////////////////////////////
@interface TLTweetsLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, readwrite) NSArray *searchResults;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *twitterAccountType;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) RACSubject *executeSearchSignal;

@end

////////////////////////////////////////////////////////////////////////////////
@implementation TLTweetsLocationManager

@synthesize accountStore = _accountStore;
@synthesize twitterAccountType = _twitterAccountType;
@synthesize locationManager = _locationManager;
@synthesize updateInterval = _updateInterval;
@synthesize searchResults = _searchResults;
@synthesize delegate = _delegate;
@synthesize searchRadius = _searchRadius;
@synthesize updateTimer = _updateTimer;
@synthesize executeSearchSignal = _executeSearchSignal;
@synthesize maxResultsCount = _maxResultsCount;

#pragma mark -

- (instancetype)init
{
	self = [super init];
	if (nil != self)
	{
		_updateInterval = 10.0;
		_searchRadius = 1.0;
		_maxResultsCount = 5;
	}
	
	return self;
}

- (void)dealloc
{
	[_updateTimer invalidate];
	_updateTimer = nil;
	
	[_executeSearchSignal sendCompleted];
	_executeSearchSignal = nil;
}

- (CLLocationManager *)locationManager
{
	if (nil == _locationManager)
	{
		_locationManager = [CLLocationManager new];
		_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		_locationManager.delegate = self;
	}
	
	return _locationManager;
}

- (ACAccountStore *)accountStore
{
	if (nil == _accountStore)
	{
		_accountStore = [ACAccountStore new];
	}
	
	return _accountStore;
}

- (ACAccountType *)twitterAccountType
{
	if (nil == _twitterAccountType)
	{
		_twitterAccountType = [self.accountStore
					accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	}
	
	return _twitterAccountType;
}

#pragma mark -

- (void)startSearchingTwits
{
	if (nil != self.executeSearchSignal)
	{
		// We're already started search
		return;
	}
	
	self.executeSearchSignal = [RACSubject subject];
	[self.executeSearchSignal subscribeNext:
	^(id x)
	{
		[[[[self requestAccessToTwitterSignal]
		then:
		^RACSignal *
		{
            [self.locationManager requestAlwaysAuthorization];
			return [self signalForSearchWithLocation:self.locationManager.location];
		}]
		deliverOn:[RACScheduler mainThreadScheduler]]
		subscribeNext:
		^(NSArray *inFoundTwits)
		{
			NSLog(@"Search result = %@", inFoundTwits);
			[self installUpdateTimer];
			[self notifyWithResults:inFoundTwits];
		}
		error:
		^(NSError *error)
		{
			NSLog(@"Error: %@", error);
			[self installUpdateTimer];
			[self notifyError:error];
		}];
	}];
	
	RACSignal *locationAccessGranted = [[self rac_signalForSelector:@selector(
        locationManager:didChangeAuthorizationStatus:)
        fromProtocol:@protocol(CLLocationManagerDelegate)]
	map:^id(RACTuple *inArgs)
	{
		BOOL result = NO;
	
		CLAuthorizationStatus locationStatus = (CLAuthorizationStatus)
            [inArgs.second unsignedIntegerValue];
        if (kCLAuthorizationStatusNotDetermined == locationStatus)
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
		else
		{
			result = (kCLAuthorizationStatusAuthorizedAlways == locationStatus ||
                kCLAuthorizationStatusAuthorizedWhenInUse == locationStatus);
		}
		
		return @(result);
	}];
	
	@weakify(self)
	[locationAccessGranted subscribeNext:
	^(NSNumber *inLocationAccessGranted)
	{
		@strongify(self)
		if (inLocationAccessGranted.boolValue)
		{
			[self.executeSearchSignal sendNext:nil];
		}
		else
		{
			[self notifyError:[self errorWithCode:
						kTLTweetsLocationManagerErrorAccessToLocationDenied]];
		}
	}];

    [self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startUpdatingLocation];
	if (kCLAuthorizationStatusAuthorizedWhenInUse == [CLLocationManager authorizationStatus])
	{
		// Start initial search
		[self.executeSearchSignal sendNext:nil];
	}
}

- (void)installUpdateTimer
{
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval
        target:self selector:@selector(updateTimerFired:)
        userInfo:nil repeats:NO];
}

- (void)invalidateTimer
{
	[self.updateTimer invalidate];
	self.updateTimer = nil;
}

- (void)updateTimerFired:(NSTimer *)inTimer
{
	[self.executeSearchSignal sendNext:nil];
}

- (RACSignal *)requestAccessToTwitterSignal
{
	NSError *accessError = [self errorWithCode:kTLTweetsLocationManagerErrorAccessToTwitsDenied];

	@weakify(self)
	return [RACSignal createSignal:
	^RACDisposable *(id<RACSubscriber> subscriber)
	{
		// Request access to twitter
		@strongify(self)
		[self.accountStore requestAccessToAccountsWithType:self.twitterAccountType
            options:nil completion:
		^(BOOL granted, NSError *error)
		{
            // Handle the response
            if (!granted)
            {
                [subscriber sendError:accessError];
            }
            else
            {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
		}];
		return nil;
	}];
}

- (SLRequest *)requestforTwitterSearchWithLocation:(CLLocation *)aLocation
{
	NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
	CLLocationCoordinate2D coordinate = aLocation.coordinate;
	NSString *locationString = [NSString stringWithFormat:@"%f,%f,%fkm",
        coordinate.latitude, coordinate.longitude, self.searchRadius];
	NSDictionary *params = @{@"q" : @"", @"geocode" : locationString};

	SLRequest *request =  [SLRequest requestForServiceType:SLServiceTypeTwitter
        requestMethod:SLRequestMethodGET URL:url parameters:params];

	return request;
}

- (RACSignal *)signalForSearchWithLocation:(CLLocation *)aLocation
{
	NSError *noAccountsError = [self errorWithCode:
        kTLTweetsLocationManagerErrorNoTwitAccounts];

	NSError *invalidResponseError = [self errorWithCode:
        kTLTweetsLocationManagerErrorInvalidServerResponse];

	@weakify(self)
	void (^signalBlock)(RACSubject *subject) =
	^(RACSubject *subject)
	{
		@strongify(self);
		if (nil == aLocation)
		{
			[subject sendNext:@[]];
			return;
		}
		// Create the request
		SLRequest *request = [self requestforTwitterSearchWithLocation:aLocation];

		NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:
            self.twitterAccountType];
		if (0 == twitterAccounts.count)
		{
			[subject sendError:noAccountsError];
			return;
		}
		[request setAccount:[twitterAccounts lastObject]];

		// Perform the request
		[request performRequestWithHandler:
		^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
		{
			if (200 == urlResponse.statusCode)
			{
				// On success, parse the response
				NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:
                    responseData options:NSJSONReadingAllowFragments error:nil];
							
				NSArray *statuses = timelineData[@"statuses"];
				NSMutableArray *foundTweets = [NSMutableArray arrayWithCapacity:
                    timelineData.allKeys.count];
				for (NSDictionary *status in statuses)
				{
					TLTweet *tweet = [TLTweet tweetWithStatusInfo:status];
					[foundTweets addObject:tweet];
				}
							
				[subject sendNext:foundTweets];
				[subject sendCompleted];
			}
			else
			{
				// Send an error on failure
				[subject sendError:invalidResponseError];
			}
		}];
	};

	RACSignal *signal = [RACSignal startLazilyWithScheduler:[RACScheduler scheduler]
        block:signalBlock];

	return signal;
}

- (void)stopSearchingTwits
{
	if (nil != self.executeSearchSignal)
	{
		[self.locationManager stopUpdatingLocation];

		[self.executeSearchSignal sendCompleted];
		self.executeSearchSignal = nil;
		[self invalidateTimer];
	}
}

#pragma mark -

- (void)notifyWithResults:(NSArray *)inResults
{
	NSArray *results = inResults;
	if (inResults.count > self.maxResultsCount)
	{
		results = [inResults subarrayWithRange:NSMakeRange(0, self.maxResultsCount)];
	}
	self.searchResults = results;
	
	if ([self.delegate respondsToSelector:
        @selector(tweetsLocationManager:didReceiveResults:)])
	{
		[self.delegate tweetsLocationManager:self didReceiveResults:results];
	}
}

- (void)notifyError:(NSError *)inError
{
	if ([self.delegate respondsToSelector:
        @selector(tweetsLocationManager:didFailWithError:)])
	{
		[self.delegate tweetsLocationManager:self didFailWithError:inError];
	}
}

- (NSError *)errorWithCode:(TLTweetsLocationManagerError)inErrorCode
{
    NSDictionary *userInfo = [self userInfoForErrorCode:inErrorCode];
	return [NSError errorWithDomain:kTLTweetsLocationManagerErrorDomain
        code:inErrorCode userInfo:userInfo];
}

- (NSDictionary *)userInfoForErrorCode:(TLTweetsLocationManagerError)inErrorCode
{
    static NSDictionary *sUserInfos = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sUserInfos = @{
        @(kTLTweetsLocationManagerErrorAccessToTwitsDenied) :
            @{NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot access Twitter account", ""),
            NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please make sure you have granted access for this app.", "")
            },
        @(kTLTweetsLocationManagerErrorAccessToLocationDenied) :
            @{NSLocalizedDescriptionKey : NSLocalizedString(@"Location information is unavailable", ""),
            NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please make sure you have granted access for this app.", "")
            },
        @(kTLTweetsLocationManagerErrorNoTwitAccounts) :
            @{NSLocalizedDescriptionKey : NSLocalizedString(@"No Twitter accounts found", ""),
            NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please make sure you have a valid Twitter account", "")
            },
//        @(kTLTweetsLocationManagerErrorInvalidServerResponse) :
//            @{NSLocalizedDescriptionKey : NSLocalizedString(@"The ", ""),
//            NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please make sure you have a valid Twitter account", "")
//            }
        };
    });
    
    return sUserInfos[@(inErrorCode)];
}

@end
