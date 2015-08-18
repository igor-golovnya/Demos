//
//  DetailViewController.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTDetailViewController.h"
#import "PBTBrowserItem.h"
#import "PBTSmartImageView.h"

@interface PBTDetailViewController ()

@property (weak, nonatomic) IBOutlet PBTSmartImageView *imageView;

@end

@implementation PBTDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(PBTBrowserItem *)newDetailItem
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
    // Update the user interface for the detail item.
    if (self.detailItem)
    {
        self.detailDescriptionLabel.text = self.detailItem.title;
        [self.imageView displayImageAtURL:self.detailItem.imageURL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:
        NSLocalizedString(@"Delete", "") style:UIBarButtonItemStylePlain
        target:self action:@selector(deleteItem:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:
        NSLocalizedString(@"Back", "") style:UIBarButtonItemStyleDone
        target:self action:@selector(moveBack:)];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)deleteItem:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(detailViewController:wantsDeleteItem:)])
    {
        [self.delegate detailViewController:self wantsDeleteItem:self.detailItem];
    }
}

- (void)moveBack:(id)aSender
{
    if ([self.delegate respondsToSelector:@selector(detailViewControllerDidFinish:)])
    {
        [self.delegate detailViewControllerDidFinish:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
