//
//  TLMapViewController.m
//  TwitLocation
//
//  Created by Igor Golovnya on 7/17/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import "TLMapViewController.h"

#import <MapKit/MapKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <CoreLocation/CoreLocation.h>

#import "RACEXTScope.h"
#import "TLTweetsLocationManager.h"
#import "TLTableViewCell.h"
#import "TLTweet.h"
#import "TLDetailViewController.h"

////////////////////////////////////////////////////////////////////////////////
@interface TLMapViewController () <MKMapViewDelegate, TLTweetsLocationManagerDelegate,
			TLDetailViewControllerDelegate>
@property (nonatomic, strong) TLTweetsLocationManager *tweetsManager;

@end

@implementation TLMapViewController

@synthesize mapView = _mapView;
@synthesize tweetsManager = _tweetsManager;

- (void)dealloc
{
	_tweetsManager.delegate = nil;
	[_tweetsManager stopSearchingTwits];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.mapView.delegate = self;
	
	self.tweetsManager = [TLTweetsLocationManager new];
	self.tweetsManager.delegate = self;
	
	[[self rac_signalForSelector:@selector(tweetsLocationManager:didFailWithError:)
        fromProtocol:@protocol(TLTweetsLocationManagerDelegate)]
	subscribeNext:
	^(RACTuple *inTuple)
	{
		NSLog(@"TwitsManager did fail with error: %@", inTuple.second);
	}];

	[[self rac_signalForSelector:@selector(tweetsLocationManager:didReceiveResults:)
        fromProtocol:@protocol(TLTweetsLocationManagerDelegate)]
	subscribeNext:
	^(RACTuple *inTuple)
	{
		[self updateAnnotationsWithTweets:inTuple.second];
	}];
}

- (void)updateAnnotationsWithTweets:(NSArray *)inTweets
{
	NSMutableArray *addedTweets = [NSMutableArray arrayWithCapacity:inTweets.count];
	NSMutableArray *removedAnnotations = [NSMutableArray arrayWithCapacity:inTweets.count];
	
	NSArray *annotations = self.mapView.annotations;
	
	// Find newly added tweets
	for (TLTweet *tweet in inTweets)
	{
		NSArray *filteredArray = [annotations filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:
		^BOOL(id<MKAnnotation> inAnnotation, NSDictionary *inBindings)
		{
			if (![inAnnotation isKindOfClass:[MKPointAnnotation class]])
			{
				return NO;
			}

			return [[TLTweet tweetWithAnnotation:inAnnotation] isEqual:tweet];
		}]];
        
		if (0 == filteredArray.count)
		{
			// Such tweet was not found, add it
			[addedTweets addObject:tweet];
		}
	}

	// Find removed tweets
	for (id<MKAnnotation> annotation in annotations)
	{
		if (![annotation isKindOfClass:[MKPointAnnotation class]])
		{
			continue;
		}
		
		TLTweet *annotationTweet = [TLTweet tweetWithAnnotation:annotation];
		NSArray *filteredArray = [inTweets filteredArrayUsingPredicate:
					[NSPredicate predicateWithBlock:
		^BOOL(TLTweet *inTweet, NSDictionary *inBindings)
		{
			return [inTweet isEqual:annotationTweet];
		}]];
        
		if (0 == filteredArray.count)
		{
			// Such tweet was not found, so it was removed
			[removedAnnotations addObject:annotation];
		}
	}
	
	[self.mapView removeAnnotations:removedAnnotations];
	for (TLTweet *tweet in addedTweets)
	{
		// Add an annotation
		MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
		point.coordinate = tweet.location.coordinate;
		point.title = tweet.username;
		point.subtitle = tweet.status;

		[self.mapView addAnnotation:point];
	}
	
	if (0 != addedTweets.count || 0 != removedAnnotations.count)
	{
		CLLocationDistance distanceInMeters = self.tweetsManager.searchRadius * 1000 * 2.5;
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
            self.mapView.userLocation.coordinate, distanceInMeters, distanceInMeters);
		[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)inAnimated
{
	[super viewWillAppear:inAnimated];
	[self.tweetsManager startSearchingTwits];
	self.tabBarController.tabBar.backgroundColor = [UIColor
        colorWithWhite:248.0 / 255.0 alpha:1.];
}

- (void)viewDidAppear:(BOOL)inAnimated
{
	[super viewDidAppear:inAnimated];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
//				self.mapView.userLocation.coordinate, self.tweetsManager.searchRadius,
//				self.tweetsManager.searchRadius);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:inAnimated];
	[self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)viewDidDisappear:(BOOL)inAnimated
{
	[super viewDidDisappear:inAnimated];
	[self.tweetsManager stopSearchingTwits];
}

- (void)mapView:(MKMapView *)mapView
			didSelectAnnotationView:(MKAnnotationView *)view
{
	UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleTap:)];
	[view addGestureRecognizer:recognizer];
}

- (TLTweet *)tweetForAnnotationView:(MKAnnotationView *)inView
{
	TLTweet *result = nil;
	id <MKAnnotation> annotation = inView.annotation;
	TLTweet *annotataionTweet = [TLTweet new];
	annotataionTweet.username = annotation.title;
	annotataionTweet.status = annotation.subtitle;
	annotataionTweet.location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
        longitude:annotation.coordinate.longitude];
	
	NSArray *filteredTweets = [self.tweetsManager.searchResults
        filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
        @"self == %@", annotataionTweet]];
	result = filteredTweets.lastObject;
	
	return result;
}

- (void)handleTap:(UITapGestureRecognizer *)inRecognizer
{
	TLDetailViewController *destinationController = [self.storyboard
        instantiateViewControllerWithIdentifier:@"TweetDetail"];
	TLTweet *tweet = [self tweetForAnnotationView:(MKAnnotationView *)
        inRecognizer.view];
	destinationController.detailItem = tweet;
	destinationController.delegate = self;

	UINavigationController *navController = [[UINavigationController alloc]
        initWithRootViewController:destinationController];
	[self presentViewController:navController animated:YES completion:NULL];
}

- (void)detailViewControllerDidFinish:(TLDetailViewController *)inController
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	NSArray *recognizers = view.gestureRecognizers;
	for (UIGestureRecognizer *currentRecognizer in recognizers)
	{
		[currentRecognizer removeTarget:self action:@selector(handleTap:)];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
