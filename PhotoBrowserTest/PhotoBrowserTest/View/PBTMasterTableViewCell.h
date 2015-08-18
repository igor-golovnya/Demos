//
//  PBTMasterTableViewCell.h
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBTBrowserItem;

@interface PBTMasterTableViewCell : UITableViewCell

- (void)updateWithItem:(PBTBrowserItem *)anItem;

@property (nonatomic, copy) dispatch_block_t duplicateActionHandler;
@property (nonatomic, copy) dispatch_block_t deleteActionHandler;

@end
