//
//  TLMapViewController.h
//  TwitLocation
//
//  Created by Igor Golovnya on 7/17/14.
//  Copyright (c) 2014 Igor Golovnya. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
@class MKMapView;

////////////////////////////////////////////////////////////////////////////////
@interface TLMapViewController : UIViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@end
