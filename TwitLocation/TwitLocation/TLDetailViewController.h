//
//  TLDetailViewController.h
//  TwitLocation
//
//  Created by Igor Golovnya on 7/15/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

@class TLTweet;
@protocol TLDetailViewControllerDelegate;

////////////////////////////////////////////////////////////////////////////////
@interface TLDetailViewController : UIViewController

@property (strong, nonatomic) TLTweet *detailItem;

@property (nonatomic, weak) IBOutlet UIImageView *twitterAvatarView;
@property (nonatomic, weak) IBOutlet UILabel *twitterStatusText;
@property (nonatomic, weak) IBOutlet UILabel *twitterUsernameText;
@property (nonatomic, weak) IBOutlet UILabel *creationDateText;

@property (nonatomic, weak) id<TLDetailViewControllerDelegate> delegate;

@end

////////////////////////////////////////////////////////////////////////////////
@protocol TLDetailViewControllerDelegate <NSObject>
@optional

- (void)detailViewControllerDidFinish:(TLDetailViewController *)aController;

@end