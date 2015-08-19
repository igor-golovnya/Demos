//
//  TLDetailViewController.m
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import "TLDetailViewController.h"

#import "TLTweet.h"

@interface TLDetailViewController ()
- (void)configureView;
@end

@implementation TLDetailViewController

@synthesize delegate = _delegate;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
	if (_detailItem != newDetailItem)
	{
		_detailItem = newDetailItem;

		// Update the view.
		[self configureView];
	}
}

- (void)configureView
{
	if (self.detailItem)
	{
		self.twitterAvatarView.image = self.detailItem.profileImage;
		if (nil == self.twitterAvatarView.image)
		{
			NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]
                dataTaskWithRequest:[NSURLRequest requestWithURL:
                self.detailItem.profileImageUrl] completionHandler:
			^(NSData *inData, NSURLResponse *inResponse, NSError *inError)
			{
				dispatch_async(dispatch_get_main_queue(),
				^{
					self.twitterAvatarView.image = [UIImage imageWithData:inData];
				});
			}];
			[dataTask resume];
		}
		self.twitterStatusText.text = self.detailItem.status;
		self.twitterUsernameText.text = self.detailItem.username;
		self.creationDateText.text = self.detailItem.creationDate;
        
        self.navigationItem.title = self.detailItem.username;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
	
	// If the delegate is supplied, we add Done button to return to the parent
	// view controller
	if ([self.delegate respondsToSelector:@selector(detailViewControllerDidFinish:)])
	{
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Done", "A Done bar button item")
            style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
		self.navigationItem.rightBarButtonItem = addButton;
	}
}

- (void)done:(id)inSender
{
	[self.delegate detailViewControllerDidFinish:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
