//
//  MasterViewController.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBTDetailViewController;

@interface PBTMasterViewController : UITableViewController

@property (strong, nonatomic) PBTDetailViewController *detailViewController;


@end

