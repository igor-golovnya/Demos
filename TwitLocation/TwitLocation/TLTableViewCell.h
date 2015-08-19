//
//  TLTableViewCell.h
//  TwitLocation
//
//  Created by Igor Golovnya on 7/17/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *twitterAvatarView;
@property (nonatomic, weak) IBOutlet UILabel *twitterStatusText;
@property (nonatomic, weak) IBOutlet UILabel *twitterUsernameText;
@end
