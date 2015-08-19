//
//  TLMasterViewController.m
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import "TLMasterViewController.h"

#import "TLDetailViewController.h"
#import "RACEXTScope.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>

#import "TLTweetsLocationManager.h"
#import "TLTableViewCell.h"
#import "TLTweet.h"

#import "NICommonMetrics.h"

////////////////////////////////////////////////////////////////////////////////
@interface TLMasterViewController () <TLTweetsLocationManagerDelegate>
{
    NSMutableArray *_tweets;
}

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *twitterAccountType;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) TLTweetsLocationManager *tweetsManager;
@property (nonatomic, readonly) NSMutableArray *tweets;

@end

@implementation TLMasterViewController

@synthesize accountStore = _accountStore;
@synthesize twitterAccountType = _twitterAccountType;
@synthesize tweetsManager = _tweetsManager;
@synthesize tweets = _tweets;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
	_tweetsManager.delegate = nil;
	[_tweetsManager stopSearchingTwits];
}

#pragma mark -

- (NSMutableArray *)tweets
{
	if (nil == _tweets)
	{
		_tweets = [NSMutableArray new];
	}
	
	return _tweets;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIEdgeInsets insets = self.tableView.contentInset;
	insets.top = 64.0; // Offset for the navigation bar
	self.tableView.contentInset = insets;
	
	CGRect frame = self.tableView.frame;
	frame.size.height -= NIStatusBarHeight();
	self.tableView.frame = frame;
	
	self.tweetsManager = [TLTweetsLocationManager new];
	self.tweetsManager.delegate = self;
	
	[[self rac_signalForSelector:@selector(tweetsLocationManager:didFailWithError:)
        fromProtocol:@protocol(TLTweetsLocationManagerDelegate)]
        subscribeNext:
	^(RACTuple *inTuple)
	{
        NSError *error = inTuple.second;
		NSLog(@"TwitsManager did fail with error: %@", error);
        if (Nil != NSClassFromString(@"UIAlertController"))
        {
            // Check that the UIAlertController is available
            NSString *title = error.userInfo[NSLocalizedDescriptionKey];
            if (0 == title.length)
            {
                title = NSLocalizedString(@"Failed to get the tweets", "");
            }
            
            NSString *message = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
            if (0 == message.length)
            {
                message = NSLocalizedString(@"Please check that you have set up Twitter "
                    "account and allowed access to it for this app.", "");
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                style:UIAlertActionStyleDefault handler:nil];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
	}];

	[[self rac_signalForSelector:@selector(tweetsLocationManager:didReceiveResults:)
        fromProtocol:@protocol(TLTweetsLocationManagerDelegate)]
	subscribeNext:
	^(RACTuple *inTuple)
	{
		[self updateWithTweets:(NSArray *)inTuple.second];
	}];
}

- (void)updateWithTweets:(NSArray *)inTweets
{
	NSMutableArray *addedTweets = [NSMutableArray arrayWithCapacity:inTweets.count];
	NSMutableArray *removedTweets = [NSMutableArray arrayWithCapacity:inTweets.count];
	
	NSArray *oldTweets = self.tweets;
	
	// Find newly added tweets
	for (TLTweet *newTweet in inTweets)
	{
		if (![oldTweets containsObject:newTweet])
		{
			// Such tweet was not found, add it
			[addedTweets addObject:newTweet];
		}
	}

	// Find removed tweets
	for (TLTweet *tweet in oldTweets)
	{
		if (![inTweets containsObject:tweet])
		{
			// Such tweet was not found, so it was removed
			[removedTweets addObject:tweet];
		}
	}
	
	[self.tweets removeObjectsInArray:removedTweets];
	[self.tweets addObjectsFromArray:addedTweets];
	if (0 != addedTweets.count || 0 != removedTweets.count)
	{
		[self.tableView reloadData];
	}
}

- (void)viewWillAppear:(BOOL)inAnimated
{
	[super viewWillAppear:inAnimated];
	[self.tweetsManager startSearchingTwits];
}

- (void)viewDidDisappear:(BOOL)inAnimated
{
	[super viewDidDisappear:inAnimated];
	self.tweetsManager.delegate = nil;
	[self.tweetsManager stopSearchingTwits];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sCellIdentifier = @"Cell";
	TLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier
        forIndexPath:indexPath];

	TLTweet *tweet = self.tweets[indexPath.row];
	
	cell.twitterStatusText.text = tweet.status;
	cell.twitterUsernameText.text = tweet.username;

	cell.twitterAvatarView.image = tweet.profileImage;
	if (nil == cell.twitterAvatarView.image)
	{
		[[[self signalForLoadingImage:tweet.profileImageUrl.absoluteString]
            deliverOn:[RACScheduler mainThreadScheduler]]
            subscribeNext:
		^(UIImage *image)
		{
			cell.twitterAvatarView.image = image;
			tweet.profileImage = image;
		}];
	}

	return cell;
}

-(RACSignal *)signalForLoadingImage:(NSString *)inImageUrl
{
	RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];

	return [[RACSignal createSignal:
	^RACDisposable *(id<RACSubscriber> inSubscriber)
	{
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:inImageUrl]];
		UIImage *image = [UIImage imageWithData:data];
		[inSubscriber sendNext:image];
		[inSubscriber sendCompleted];
		return nil;
	}] subscribeOn:scheduler];  
}


- (BOOL)tableView:(UITableView *)inTableView canEditRowAtIndexPath:(NSIndexPath *)inIndexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TLTweet *object = self.tweets[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
