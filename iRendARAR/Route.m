//
//  Route.m
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Route.h"
#import "GPSManager.h"

@implementation Route

-(NSString* ) description {
    NSString* result = [NSString stringWithFormat:@"Longname: %@\nShortname: %@\nFilename: %@\nLatitude: %f\nLongitude: %f\n", self.longname, self.shortname, self.filename, self.coordinate.latitude, self.coordinate.longitude];
    
    return result;
}

- (float)distance {
	return [[GPSManager sharedInstance] distanceFromCurrentPositionToRoute:self];
}



@end
