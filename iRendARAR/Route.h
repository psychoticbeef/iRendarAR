//
//  Route.h
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Route : NSObject

@property (nonatomic, strong) NSString* longname;
@property (nonatomic, strong) NSString* shortname;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSURL* zipfile;


- (float)distance;

@end
