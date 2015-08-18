//
//  DetailViewController.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBTDetailViewController;
@class PBTBrowserItem;

@protocol PBTDetailViewControllerDelegate <NSObject>
@optional

- (void)detailViewController:(PBTDetailViewController *)aController
    wantsDeleteItem:(id)anItem;
- (void)detailViewControllerDidFinish:(PBTDetailViewController *)aController;

@end

@interface PBTDetailViewController : UIViewController

@property (nonatomic, weak) id<PBTDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) PBTBrowserItem *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

