//
//  GPSManager.m
//  iRendARAR
//
//  Created by Daniel Arndt on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPSManager.h"


@interface GPSManager ()

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSMutableArray* notifierCoordinate;
@property (nonatomic, retain) NSMutableArray* notifierDelegate;
@property (nonatomic, retain) NSMutableArray* notifierRadius;
@property (nonatomic, retain) NSMutableArray* notifierIdentifier;

@property (atomic) BOOL notificationsArePaused;

@end


@implementation GPSManager


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

-(CLLocationDistance)distanceFromCurrentPositionToRoute:(Route* )route {
	CLLocation* temporaryLocation = [[CLLocation alloc] initWithLatitude:route.coordinate.latitude longitude:route.coordinate.longitude];
	
//	DebugLog(@"%f %f", route.coordinate.latitude, route.coordinate.longitude);
	return [temporaryLocation distanceFromLocation:self.loc];
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

- (void)pauseNotifications:(BOOL)pause {
	self.notificationsArePaused = pause;
}

- (void)notify:(CLLocation *) currentLocation {
	if (self.notificationsArePaused) return;
	
	unsigned int i = 0;
	bool fuck_yeah = NO;
	for (CLLocation* location in self.notifierCoordinate) {
		if ([currentLocation distanceFromLocation:location] < [self.notifierRadius[i] doubleValue]) {
			fuck_yeah = YES;
			break;
		}
		i++;
	}
	
	if (fuck_yeah)
		[self.notifierDelegate[i] didArriveAtLocation:self.notifierIdentifier[i]];
}

- (void)restart {
    [_locationManager startUpdatingLocation];
}

- (void)stop {
    [self.locationManager stopUpdatingLocation];
}


@end
