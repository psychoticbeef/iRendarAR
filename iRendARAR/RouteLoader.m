//
//  RouteLoader.m
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteLoader.h"
#import "Route.h"

@interface RouteLoader ()

@property (nonatomic, strong) NSString* base_url;
@property (nonatomic, strong) NSString* list_file;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSMutableArray* routeList;
@property (readwrite, strong) NSArray* routes;

@end


@implementation RouteLoader

- (void)locationDidChange {
	NSArray* sortedArray;
    if (self.routes) {
		sortedArray = [self.routes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
			float first = [a distance];
			float second = [b distance];
			if (first == second) return NSOrderedSame;
			return first > second ? NSOrderedDescending : NSOrderedAscending;
		}];
		
		self.routes = sortedArray;
		
        DebugLog(@"The GPS receiver informed us about a new location."
				 @"Also, Routes are already loaded.");
    } else {
        DebugLog(@"The GPS receiver informed us about a new location."
				 @"The route list was not yet loaded.");
    }
}




-(id)init{
    self = [super init];

    if (self) {
        NSString* urlSettingsFile;
        NSMutableDictionary* urlSettings;

        NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
        urlSettingsFile = [bundlePath stringByAppendingPathComponent:@"url_settings.plist"];
        urlSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:urlSettingsFile];
        _base_url = urlSettings[@"base_url"];
        _list_file = urlSettings[@"list_file"];
        _url = [NSURL URLWithString:[_base_url stringByAppendingPathComponent:_list_file]];
        _delegate = NULL;
    }
    
    return self;
}

-(void)loadRoutes{
    self.routeList = [[NSMutableArray alloc] init];
    DebugLog(@"Trying to download from URL: %@", self.url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		int i = 0;
        NSError* downloadError = NULL;
		NSString* routeComponents;
		do {
			routeComponents = [NSString stringWithContentsOfURL:self.url encoding:NSUTF8StringEncoding error:&downloadError];
		} while (downloadError && i++ < 3);
		
		NSArray* routeComponentArray = [routeComponents componentsSeparatedByString:@"\n"];
		
		for (NSString* line in routeComponentArray) {
			if ([line length] > 0) {
				if ([line characterAtIndex:0] != '#') {// lines that start with # are comments
					NSArray* routeArray = [line componentsSeparatedByString:@"\t"];
					if ([routeArray count] != 5) {
						NSLog(@"Routelist Error: %@ broken in line: %@", self.list_file, line);
						NSLog(@"Got %i lines: %@", routeArray.count, routeArray);
						continue;
					}
					
					Route* route = [[Route alloc] init];
					route.longname = routeArray[0];
					route.shortname = routeArray[1];
					route.filename = routeArray[2];
					route.coordinate = CLLocationCoordinate2DMake([routeArray[3] floatValue], [routeArray[4] floatValue]);
					route.zipfile = [NSURL URLWithString:[self.base_url stringByAppendingString:route.filename]];
					
					
					[self.routeList addObject:route];
				}
			}
		}
		
		self.routes = [self.routeList copy];
			
        dispatch_async(dispatch_get_main_queue(), ^{
			if (!downloadError) {
				[self.delegate routeLoaderDidFinishLoading];
			} else {
				[self.delegate routeLoaderDidFinishWithError];
			}
        });
    });
}

@end
