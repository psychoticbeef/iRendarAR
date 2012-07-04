//
//  Route.m
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Route.h"

@implementation Route

-(NSString* ) description {
    NSString* result = [NSString stringWithFormat:@"Longname: %@\nShortname: %@\nFilename: %@\nLatitude: %f\nLongitude: %f\n", self.longname, self.shortname, self.filename, self.latitude, self.longitude];
    
    return result;
}

@end
