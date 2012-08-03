//
//  GPSManager.m
//  iRendARAR
//
//  Created by Daniel Arndt on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPSManager.h"
#import <math.h>


@interface GPSManager ()

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSMutableArray* notifierCoordinate;
@property (nonatomic, retain) NSMutableArray* notifierDelegate;
@property (nonatomic, retain) NSMutableArray* notifierRadius;
@property (nonatomic, retain) NSMutableArray* notifierIdentifier;
@property (nonatomic, retain) CLLocation* loc;

@end


@implementation GPSManager

const CGFloat d2r = M_PI / 180.0;

+(id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

-(id)init {
	self = [super init];
	
    if (self) {
        if (![CLLocationManager locationServicesEnabled]) {
            DebugLog(@"location services turned off. cannot acquire GPS signal.");
            return self;
        }
		_locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
        _delegate = NULL;
		
		_notifierCoordinate = [[NSMutableArray alloc] init];
		_notifierDelegate = [[NSMutableArray alloc] init];
		_notifierRadius = [[NSMutableArray alloc] init];
		_notifierIdentifier = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(CGFloat)distanceFromLatitude:(CGFloat)fromLatitude fromLongitude:(CGFloat)fromLongitude toLatitude:(CGFloat)toLatitude toLongitude:(CGFloat)toLongitude {
    CGFloat dlong = (toLongitude - fromLongitude) * d2r;
    CGFloat dlat = (toLatitude - fromLatitude) * d2r;
    CGFloat a1 = sin(dlat/2.0);
    CGFloat a2 = sin(dlong/2.0);
    CGFloat a = a1*a1 + cos(fromLatitude*d2r) * cos(toLatitude*d2r) * a2*a2;
    CGFloat c = 2 * atan2(sqrt(a), sqrt(1-a));
    CGFloat d = 6367 * c;
    
    return d;
}

-(CGFloat)distanceFromCurrentPosititionToLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude {
    return [self distanceFromLatitude:self.coordinate.latitude fromLongitude:self.coordinate.longitude toLatitude:latitude toLongitude:longitude];
}

-(CGFloat)distanceFromCurrentPosititionToRoute:(Route* )route {
    return [self distanceFromCurrentPosititionToLatitude:[route latitude] andLongitude:[route longitude]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
    self.coordinate = CLLocationCoordinate2DMake([newLocation coordinate].latitude, [newLocation coordinate].longitude);
	
    if ((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) || (newLocation.coordinate.longitude != oldLocation.coordinate.longitude)) {
        [self.delegate locationDidChange];
		
		[self notify:newLocation];
		self.loc = newLocation;
    }
}

- (void)notifyWhenAtLocation:(CLLocationCoordinate2D)location withRadius:(int)radius identifier:(NSString*)identifier delegate:(id<GPSManagerNotificationDelegate>)delegate {
	NSNumber *number = [NSNumber numberWithInt:radius];
	CLLocation *temporary_location = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
	
	[self.notifierCoordinate addObject:temporary_location];
	[self.notifierRadius addObject:number];
	[self.notifierDelegate addObject:delegate];
	[self.notifierIdentifier addObject:identifier];
	
	[self notify:self.loc];
}

- (void)clearNotifications {
	[self.notifierCoordinate removeAllObjects];
	[self.notifierRadius removeAllObjects];
	[self.notifierDelegate removeAllObjects];
	[self.notifierIdentifier removeAllObjects];
}

- (void)notify:(CLLocation *) currentLocation {
	int i = 0;
	for (CLLocation* location in self.notifierCoordinate) {
		if ([currentLocation distanceFromLocation:location] < [self.notifierRadius[i] doubleValue]) {
			[self.notifierDelegate[i] didArriveAtLocation:self.notifierIdentifier[i]];
		}
		i++;
	}
}


@end
