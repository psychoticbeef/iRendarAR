//
//  GPSManager.h
//  iRendARAR
//
//  Created by Daniel Arndt on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import <CoreLocation/CoreLocation.h>

@protocol GPSManagerDelegate
- (void)locationDidChange;
@end

@protocol GPSManagerNotificationDelegate
- (void)didArriveAtLocation:(NSString*)identifer;
@end

@interface GPSManager : NSObject <CLLocationManagerDelegate>

+(id)sharedInstance;

-(CGFloat)distanceFromLatitude:(CGFloat)fromLatitude fromLongitude:(CGFloat)fromLongitude toLatitude:(CGFloat)toLatitude toLongitude:(CGFloat)toLongitude;

-(CGFloat)distanceFromCurrentPosititionToLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;

-(CGFloat)distanceFromCurrentPosititionToRoute:(Route* )route;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

- (void)notifyWhenAtLocation:(CLLocationCoordinate2D)location withRadius:(int)radius identifier:(NSString*)identifier delegate:(id<GPSManagerNotificationDelegate>)delegate;
- (void)clearNotifications;

@property (weak) id<GPSManagerDelegate> delegate;


@end
