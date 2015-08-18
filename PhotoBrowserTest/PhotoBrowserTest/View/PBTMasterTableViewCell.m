//
//  PBTMasterTableViewCell.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTMasterTableViewCell.h"

#import "PBTSmartImageView.h"
#import "PBTBrowserItem.h"

@interface PBTMasterTableViewCell ()

@property (weak, nonatomic) IBOutlet PBTSmartImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *duplicateButton;

@property (nonatomic, strong) PBTBrowserItem *item;

@end

@implementation PBTMasterTableViewCell

- (IBAction)deleteItem:(id)sender
{
    if (self.deleteActionHandler)
    {
        self.deleteActionHandler();
    }
}
- (IBAction)duplicateItem:(id)sender
{
    if (self.duplicateActionHandler)
    {
        self.duplicateActionHandler();
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)updateWithItem:(PBTBrowserItem *)anItem
{
    self.item = anItem;
    self.titleLabel.text = anItem.title;

    [self.itemImageView displayImageAtURL:anItem.thumbnailImageURL];
}

@end
