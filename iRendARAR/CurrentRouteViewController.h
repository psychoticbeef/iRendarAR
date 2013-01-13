//
//  CurrentRouteViewController.h
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARViewController.h"
#import "Graph.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "StationViewController.h"
#import <MapKit/MKPolyline.h>
#import "GPSManager.h"



@interface CurrentRouteViewController : UIViewController <UIAccelerometerDelegate, MKMapViewDelegate, GPSManagerNotificationDelegate, UIAlertViewDelegate, MultipleChoiceDelegate, ARViewDelegate>

typedef NS_ENUM (NSUInteger, AppState) { NONE, CAMERA, MAP };

- (void)loadXML;

@end
