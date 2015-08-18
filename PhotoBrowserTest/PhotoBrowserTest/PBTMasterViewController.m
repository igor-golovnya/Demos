//
//  MasterViewController.m
//  PhotoBrowserTest
//
//  Created by Igor Golovnya on 7/4/15.
//  Copyright (c) 2015 Igor Golovnya. All rights reserved.
//

#import "PBTMasterViewController.h"

#import "PBTDetailViewController.h"
#import "PBTMasterTableViewCell.h"
#import "PBTImageProvider.h"
#import "PBTBrowserItem.h"

#import "PBTDownloader.h"
#import "PBTBrowserItem.h"

@interface PBTMasterViewController () <PBTDetailViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, readonly) PBTDownloader *itemsDownloader;

@end

@implementation PBTMasterViewController

@synthesize itemsDownloader = _itemsDownloader;

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (PBTDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self.itemsDownloader downloadMetadataWithCompletion:
    ^(NSArray *inBrowserItems, NSError *inError)
    {
        // TODO: Handle errors
        if (nil != inBrowserItems)
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                self.objects = [inBrowserItems mutableCopy];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[PBTImageProvider sharedProvider] resetCache];
}

#pragma mark -
- (NSMutableArray *)objects
{
    if (nil == _objects)
    {
        _objects = [NSMutableArray new];
    }
    
    return _objects;
}

- (PBTDownloader *)itemsDownloader
{
    if (nil == _itemsDownloader)
    {
        _itemsDownloader = [PBTDownloader new];
    }
    
    return _itemsDownloader;
}

#pragma mark -
- (void)detailViewController:(PBTDetailViewController *)aController
    wantsDeleteItem:(id)anItem
{
    [self deleteItemAtIndexPath:[self indexPathOfItem:anItem]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSIndexPath *)indexPathOfItem:(PBTBrowserItem *)anItem
{
    return [NSIndexPath indexPathForRow:[self.objects indexOfObjectIdenticalTo:anItem]
        inSection:0];
}

- (void)detailViewControllerDidFinish:(PBTDetailViewController *)aController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PBTBrowserItem *object = self.objects[indexPath.row];
        PBTDetailViewController *controller = (PBTDetailViewController *)[[segue destinationViewController] topViewController];
        controller.delegate = self;
        controller.detailItem = object;
                
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBTMasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MasterCell" forIndexPath:indexPath];
    [cell updateWithItem:self.objects[indexPath.row]];
    
    WEAKIFY(self);
    WEAKIFY(cell);
    cell.duplicateActionHandler =
    ^{
        STRONGIFY(self);
        STRONGIFY(cell);
        [self duplicateItemAtIndexPath:[self.tableView indexPathForCell:cell]];
    };

    cell.deleteActionHandler =
    ^{
        STRONGIFY(self);
        STRONGIFY(cell);
        [self deleteItemAtIndexPath:[self.tableView indexPathForCell:cell]];
    };

    return cell;
}

- (void)duplicateItemAtIndexPath:(NSIndexPath *)indexPath
{
    PBTBrowserItem *item = self.objects[indexPath.row];
    PBTBrowserItem *newItem = [PBTBrowserItem new];
    newItem.id = item.id;
    newItem.imageURL = item.imageURL;
    newItem.title = item.title;
    
    NSInteger upOrDown = self.randomBoolean;
    NSInteger newIndex = indexPath.row + upOrDown;
    [self.objects insertObject:newItem atIndex:newIndex];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]]
        withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)randomBoolean
{
    return (arc4random() % 2 == 0);
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (NSNotFound != indexPath.row)
    {
        [self.objects removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
